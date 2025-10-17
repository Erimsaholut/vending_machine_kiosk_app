import '../../widgets/background_scaffold.dart';
import 'package:flutter/material.dart';
import '../../core/sales_data.dart';
import 'dart:async';

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

class _PreparingPageState extends State<PreparingPage> with SingleTickerProviderStateMixin {
  Timer? _timer;
  double _progress = 0;
  late final int _totalMs;
  int _elapsedMs = 0;
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;

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

    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) async {
      setState(() {
        _elapsedMs += 50;
        _progress = _elapsedMs / _totalMs;
      });

      if (_elapsedMs >= _totalMs) {
        _timer?.cancel();
        // Satışı kaydet
        await SalesData.instance.sellDrink(
          title: widget.title,
          volume: widget.volume,
          priceTl: double.tryParse(widget.price) ?? 0.0,
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _opacityController.dispose();
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
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF026B55)),
                backgroundColor: const Color(0xFF4EF2C0),
              ),
            ),
            const SizedBox(height: 50),
            Text("${(_progress * 100).toStringAsFixed(0)}%",
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_progress >= 1.0)
              const Text("Afiyet olsun!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
