import 'package:flutter/material.dart';

class SalesClosedPage extends StatelessWidget {
  const SalesClosedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTurkish = Localizations.localeOf(context).languageCode.toLowerCase() == 'tr';
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
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
      ),
    );
  }
}
