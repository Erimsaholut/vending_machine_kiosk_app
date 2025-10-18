import 'dart:async';
import 'package:flutter/material.dart';
import '../core/i18n.dart';
import '../widgets/background_scaffold.dart';

class RefundAnimationPage extends StatefulWidget {
  const RefundAnimationPage({super.key});

  @override
  State<RefundAnimationPage> createState() => _RefundAnimationPageState();
}

class _RefundAnimationPageState extends State<RefundAnimationPage> {
  bool _refundComplete = false;

  @override
  void initState() {
    super.initState();
    // 5 saniye sonra iade işlemi tamamlanmış olacak
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _refundComplete = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(trEn("İade", "Refund")),
        backgroundColor: Colors.transparent,
      ),
      child: Center(
        child: _refundComplete
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
                  const SizedBox(height: 20),
                  Text(
                    trEn("Ücret iadesi başarı ile yapıldı",
                        "Refund completed successfully"),
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    trEn(
                        "Ürün doldurulurken bir hata ile karşılaşıldı.\nÜcret iadesi yapılıyor...",
                        "An error occurred while preparing the product.\nProcessing refund..."),
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
