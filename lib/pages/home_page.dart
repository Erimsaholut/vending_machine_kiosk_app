import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/admin_keypad_dialog.dart';
import 'package:flutter/material.dart';
import 'sales_closed_page.dart';
import 'product_page.dart';
import '../core/i18n.dart';
import 'sales_closed_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Stack(
        children: [
          // Background wallpaper
          Positioned.fill(
            child: Image.asset(
              'assets/wallpapers/main_background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Settings (top right)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () async {
                final code = await showDialog<String>(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => const AdminKeypadDialog(length: 8),
                );
                if (!mounted) return;
                if (code != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        trEn('Girilen parola: $code', 'Entered code: $code'),
                      ),
                    ),
                  );
                }
              },
              child: const Opacity(
                opacity: 0.3,
                child: Icon(Icons.settings, size: 24),
              ),
            ),
          ),

          // Language switcher (top left)
          Positioned(
            top: 8,
            left: 8,
            child: TextButton(
              onPressed: () => setState(() => isEnglish.value = !isEnglish.value),
              child: const Text("TR/EN"),
            ),
          ),

          // Logo
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

          // Start button (bottom center)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(300, 100),
                ),
                onPressed: () async {
                  // Firestore’dan status kontrolü
                  final doc = await FirebaseFirestore.instance
                      .collection('machines')
                      .doc('M-0001')
                      .get();

                  final data = doc.data();
                  final isActive = data?['status']?['isActive'] ?? true;

                  if (!isActive) {
                    // Satış kapalı → özel sayfaya yönlendir
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SalesClosedPage()),
                    );
                  } else {
                    // Satış açık → ProductPage
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProductPage()),
                    );
                  }
                },
                child: Text(
                  trEn('Başla', 'Start'),
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}