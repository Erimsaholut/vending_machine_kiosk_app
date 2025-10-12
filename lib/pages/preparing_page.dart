import '../../core/sales_data.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/i18n.dart';
import '../../widgets/background_scaffold.dart';

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

class _PreparingPageState extends State<PreparingPage> {
  Timer? _timer;
  double _progress = 0.0;
  late final int _totalMs;
  int _elapsedMs = 0;

  @override
  void initState() {
    super.initState();
    _totalMs = (widget.seconds * 1000);
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      setState(() {
        _elapsedMs += 50;
        if (_elapsedMs >= _totalMs) {
          _elapsedMs = _totalMs;
          _progress = 1.0;
          _timer?.cancel();

          // Satışı kaydet (Firebase üzerinden)
          final sales = SalesData();
          if (widget.title.contains('Küçük') || widget.title.contains('Small')) {
            sales.sellSmall(priceTl: double.tryParse(widget.price) ?? 30);
          } else {
            sales.sellLarge(priceTl: double.tryParse(widget.price) ?? 45);
          }

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          });
        } else {
          _progress = _elapsedMs / _totalMs;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          '${trEn('Hazırlanıyor','Preparing')} – ${widget.title} ${widget.volume}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                strokeWidth: 10,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              trEn('İçeceğiniz hazırlanıyor','Your drink is being prepared'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 8),
            Text("%${(_progress * 100).toStringAsFixed(0)}"),
            const SizedBox(height: 24),
            if (_progress >= 1.0)
              Text(
                trEn('Afiyet olsun!','Enjoy!'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}