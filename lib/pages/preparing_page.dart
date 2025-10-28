// SPDX-License-Identifier: MIT
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/sales_data.dart';
import '../../widgets/background_scaffold.dart';
import '../home_page.dart';

// --- EKLENENLER: Cihaz entegrasyonu (UI değişmedi) ---
import '../../buzlime_integration/device_controller.dart';

class PreparingPage extends StatefulWidget {
  final String title;
  final String volume;
  final String price;
  final int seconds;

  const PreparingPage({
    super.key,
    required this.title,
    required this.volume,
    required this.price,
    required this.seconds,
  });

  @override
  State<PreparingPage> createState() => _PreparingPageState();
}

class _PreparingPageState extends State<PreparingPage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  double _progress = 0;
  late final int _totalMs;
  int _elapsedMs = 0;
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;

  // --- EKLENENLER: Cihaz kontrolcüsü ve akış ---
  DeviceController? _ctrl;
  StreamSubscription? _stepSub;
  StreamSubscription? _telSub;

  bool _deviceMode = false; // Arduino’ya bağlandıysak true
  bool _finished = false; // Çift bitirmeyi önlemek için

  bool get _isLarge {
    final v = widget.volume.toLowerCase();
    return v.contains('400') || v.contains('büyük') || v.contains('large');
  }

  @override
  void initState() {
    super.initState();
    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _opacityAnimation = CurvedAnimation(
      parent: _opacityController,
      curve: Curves.easeInOut,
    );

    _totalMs = widget.seconds * 1000;

    // --- Mevcut görsel timer KORUNDU ---
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) async {
      if (_finished) return; // bitmişse dokunma
      setState(() {
        _elapsedMs += 50;
        if (_elapsedMs > _totalMs) _elapsedMs = _totalMs;
        _progress = _totalMs == 0 ? 0 : _elapsedMs / _totalMs;
      });

      // Eğer Arduino modunda DEĞİLSEK, eski davranış: süre dolunca bitir
      if (!_deviceMode && _elapsedMs >= _totalMs) {
        await _completeSaleAndGoHome(); // eski davranış AYNI
      }
    });

    // --- EKLENEN: Arduino akışını başlat (başarırsa deviceMode=true) ---
    _startDeviceFlow();
  }

  Future<void> _startDeviceFlow() async {
    try {
      final ctrl = DeviceController();
      final ok = await ctrl.connect();
      if (!ok) {
        // Bağlanamadı: timer tabanlı “eski” akışa bırak
        return;
      }

      _ctrl = ctrl;
      _deviceMode = true;

      // Adım akışını dinle (progress görselini hafifçe adımlara yaklaştır)
      _stepSub = ctrl.stepStream.stream.listen((step) {
        if (_finished) return;

        // Adım eşleşmesi ile görsel ilerlemeyi nazikçe ileri it
        // (UI aynı; sadece value hesaplamasına küçük dokunuş)
        final bump = switch (step) {
          PrepStep.cup => 0.20,
          PrepStep.valveTemp => 0.40,
          PrepStep.tof1 => 0.50,
          PrepStep.water => 0.75,
          PrepStep.tof2 => 0.80,
          PrepStep.doorOpen => 0.90,
          PrepStep.takePrompt => 0.95,
          PrepStep.doorClose => 0.98,
          PrepStep.done => 1.0,
          _ => null,
        };
        if (bump != null && bump > _progress) {
          setState(() => _progress = bump);
        }

        if (step == PrepStep.done) {
          _finishFromDevice();
        } else if (step == PrepStep.error) {
          // Hata: eski davranışta “satış bitir” yoktu; burada da bitirmiyoruz.
          // İstersen burada alternatif ekran/kilit akışı tetikleyebilirsin.
        }
      });

      // Telemetri (şimdilik UI’de göstermiyoruz; entegrasyon hazır dursun)
      _telSub = ctrl.telemetryStream.stream.listen((_) {});

      // Akışı başlat (300 mL → small, 400 mL → large)
      // BYPASS sensörlerde ok:true dönecektir.
      // unawaited: UI’yi bloklamadan çalışsın
      // ignore: unawaited_futures
      ctrl.run(BuzlimeFlow(large: _isLarge));
    } catch (_) {
      // Herhangi bir istisnada, “eski” timer davranışına geri düş
      _deviceMode = false;
    }
  }

  Future<void> _finishFromDevice() async {
    if (_finished) return;
    _finished = true;

    // Görsel olarak da %100’e tamamla
    setState(() => _progress = 1.0);

    await _completeSaleAndGoHome();
  }

  Future<void> _completeSaleAndGoHome() async {
    if (_finished) return; // Satış bir kez yazılsın
    _finished = true;
    _timer?.cancel();

    // Satışı kaydet (eski kod KORUNDU)
    try {
      await SalesData.instance.sellDrink(
        title: widget.title,
        volume: widget.volume,
        priceTl: double.tryParse(widget.price) ?? 0.0,
      );
    } catch (e) {
      debugPrint('SalesData error: $e');
    }

    if (!mounted) return;

    // 2 saniye bekle, sonra ana menüye dön (eski kod KORUNDU)
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _opacityController.dispose();

    // --- EK: cihaz kaynaklarını kapat ---
    _stepSub?.cancel();
    _telSub?.cancel();
    _ctrl?.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      extendBodyBehindAppBar: true,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _opacityAnimation,
              child: Image.asset(
                'assets/buttons_new/product.png',
                height: 324,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              height: 120,
              width: 120,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: 22,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF026B55)),
                backgroundColor: const Color(0xFF4EF2C0),
              ),
            ),
            const SizedBox(height: 50),
            Text(
              "${(_progress * 100).toStringAsFixed(0)}%",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_progress >= 1.0)
              const Text(
                "Afiyet olsun !",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
