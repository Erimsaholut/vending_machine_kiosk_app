import 'package:flutter/material.dart';
import '../core/i18n.dart';

class SalesClosedPage extends StatelessWidget {
  const SalesClosedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 48, // larger size
            weight: 800, // thicker stroke (Flutter 3.22+)
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isTurkish
                  ? 'assets/wallpapers/out_of_order_tr.png'
                  : 'assets/wallpapers/out_of_order_en.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}