import 'package:flutter/material.dart'
    '';
import '../widgets/background_scaffold.dart';

class SalesClosedPage extends StatelessWidget {
  const SalesClosedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/wallpapers/main_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: IgnorePointer(
              child: Image.asset(
                'assets/buttons/logo.png',
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.width * 0.6,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Şu anda satış yapamıyoruz.\nEn kısa sürede hizmetinizde olacağız.\nİlginiz için teşekkür ederiz.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Geri Dön"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
