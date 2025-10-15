import 'package:flutter/material.dart';

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
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/wallpapers/out_of_order_tr.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}