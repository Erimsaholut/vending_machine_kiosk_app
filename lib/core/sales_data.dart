import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'error_codes.dart';

class SalesData {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String machineId = 'M-0001';

  Future<void> _ensureDailyLog(String day) async {
    final logRef = _db.collection('machines').doc(machineId)
        .collection('profit_logs').doc(day);

    await logRef.set({
      'timestamp': FieldValue.serverTimestamp(),
      'totalProfit': 0.0,
      'smallSold': 0,
      'largeSold': 0,
      'smallTl': 0.0,
      'largeTl': 0.0,
      'refunds': {
        'total': 0,
        'amountTl': 0.0,
        'amountMl': 0,
        'details': {'overfreeze': 0, 'cupDrop': 0, 'other': 0},
      },
    }, SetOptions(merge: true));
  }

  /// Küçük bardak satışı
  Future<void> sellSmall({required double priceTl}) async {
    final day = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final machineRef = _db.collection('machines').doc(machineId);
    final logRef = machineRef.collection('profit_logs').doc(day);

    await _ensureDailyLog(day);

    await _db.runTransaction((tx) async {
      final mSnap = await tx.get(machineRef);
      final m = (mSnap.data() ?? {});
      final inv = Map<String, dynamic>.from(m['inventory'] ?? {});
      final lv = Map<String, dynamic>.from(m['levels'] ?? {});
      final dp = Map<String, dynamic>.from(m['daily_profit'] ?? {'current_day': day, 'profit_today': 0.0});
      final sales = Map<String, dynamic>.from(m['sales'] ?? {'smallSold': 0, 'largeSold': 0, 'smallTl': 0.0, 'largeTl': 0.0});

      final cups = (inv['smallCups'] ?? 0) as int;
      final liquid = (lv['liquid'] ?? 0) as int;
      if (cups <= 0 || liquid < 300) throw StateError('Yetersiz stok.');

      inv['smallCups'] = cups - 1;
      lv['liquid'] = liquid - 300;
      dp['current_day'] = day;
      dp['profit_today'] = (dp['profit_today'] ?? 0.0) + priceTl;
      sales['smallSold'] = (sales['smallSold'] ?? 0) + 1;
      sales['smallTl'] = (sales['smallTl'] ?? 0.0) + priceTl;

      tx.update(machineRef, {
        'inventory': inv,
        'levels': lv,
        'daily_profit': dp,
        'profit_total': FieldValue.increment(priceTl),
        'sales': sales,
      });

      final lSnap = await tx.get(logRef);
      final l = (lSnap.data() ?? {});
      final lSales = {
        'smallSold': (l['smallSold'] ?? 0) + 1,
        'smallTl': (l['smallTl'] ?? 0.0) + priceTl,
      };
      tx.set(logRef, lSales, SetOptions(merge: true));
    });
  }

  /// Büyük bardak satışı
  Future<void> sellLarge({required double priceTl}) async {
    final day = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final machineRef = _db.collection('machines').doc(machineId);
    final logRef = machineRef.collection('profit_logs').doc(day);

    await _ensureDailyLog(day);

    await _db.runTransaction((tx) async {
      final mSnap = await tx.get(machineRef);
      final m = (mSnap.data() ?? {});
      final inv = Map<String, dynamic>.from(m['inventory'] ?? {});
      final lv = Map<String, dynamic>.from(m['levels'] ?? {});
      final dp = Map<String, dynamic>.from(m['daily_profit'] ?? {'current_day': day, 'profit_today': 0.0});
      final sales = Map<String, dynamic>.from(m['sales'] ?? {'smallSold': 0, 'largeSold': 0, 'smallTl': 0.0, 'largeTl': 0.0});

      final cups = (inv['largeCups'] ?? 0) as int;
      final liquid = (lv['liquid'] ?? 0) as int;
      if (cups <= 0 || liquid < 400) throw StateError('Yetersiz stok.');

      inv['largeCups'] = cups - 1;
      lv['liquid'] = liquid - 400;
      dp['current_day'] = day;
      dp['profit_today'] = (dp['profit_today'] ?? 0.0) + priceTl;
      sales['largeSold'] = (sales['largeSold'] ?? 0) + 1;
      sales['largeTl'] = (sales['largeTl'] ?? 0.0) + priceTl;

      tx.update(machineRef, {
        'inventory': inv,
        'levels': lv,
        'daily_profit': dp,
        'profit_total': FieldValue.increment(priceTl),
        'sales': sales,
      });

      final lSnap = await tx.get(logRef);
      final l = (lSnap.data() as Map<String, dynamic>? ?? {});
      final lSales = {
        'largeSold': (l['largeSold'] ?? 0) + 1,
        'largeTl': (l['largeTl'] ?? 0.0) + priceTl,
      };
      tx.set(logRef, lSales, SetOptions(merge: true));
    });
  }

  /// İade kaydı
  Future<void> logRefund({
    required bool isSmall,
    required double amountTl,
    required int amountMl,
    required String errorCode,
  }) async {
    if (!RefundErrorCodes.isValid(errorCode)) {
      throw ArgumentError('Geçersiz hata kodu: $errorCode');
    }

    final day = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final machineRef = _db.collection('machines').doc(machineId);
    final logRef = machineRef.collection('profit_logs').doc(day);

    await _ensureDailyLog(day);

    await _db.runTransaction((tx) async {
      // Tüm okumalar transaction başında
      final logSnap = await tx.get(logRef);
      final mSnap = await tx.get(machineRef);

      final ldata = (logSnap.data() ?? {});
      final mdata = (mSnap.data() as Map<String, dynamic>? ?? {});

      // Günlük log refund güncelleme
      final lrefunds = Map<String, dynamic>.from(ldata['refunds'] ?? {});
      final ldetails = Map<String, dynamic>.from(lrefunds['details'] ?? {});
      lrefunds['total'] = (lrefunds['total'] ?? 0) + 1;
      lrefunds['amountTl'] = (lrefunds['amountTl'] ?? 0.0) + amountTl;
      lrefunds['amountMl'] = (lrefunds['amountMl'] ?? 0) + amountMl;
      ldetails[errorCode] = (ldetails[errorCode] ?? 0) + 1;
      lrefunds['details'] = ldetails;
      tx.set(logRef, {'refunds': lrefunds}, SetOptions(merge: true));

      // Makine genel refund güncelleme
      final mrefunds = Map<String, dynamic>.from(mdata['refunds'] ?? {});
      final mdetails = Map<String, dynamic>.from(
        (mrefunds['details'] ?? {'overfreeze': 0, 'cupDrop': 0, 'other': 0}),
      );
      mrefunds['total'] = (mrefunds['total'] ?? 0) + 1;
      mrefunds['amountTl'] = (mrefunds['amountTl'] ?? 0.0) + amountTl;
      mrefunds['amountMl'] = (mrefunds['amountMl'] ?? 0) + amountMl;
      mdetails[errorCode] = (mdetails[errorCode] ?? 0) + 1;
      mrefunds['details'] = mdetails;
      tx.set(machineRef, {'refunds': mrefunds}, SetOptions(merge: true));
    });

    // Transaction dışında log ekleme
    await logRef.collection('refund_logs').add({
      'timestamp': FieldValue.serverTimestamp(),
      'isSmall': isSmall,
      'errorCode': errorCode,
      'amountTl': amountTl,
      'amountMl': amountMl,
    });
  }
}