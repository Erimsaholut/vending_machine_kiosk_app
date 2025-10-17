import 'package:buzi_kiosk/widgets/admin_keypad_dialog.dart';
import 'package:buzi_kiosk/pages/sales_closed_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buzi_kiosk/pages/product_page.dart';
import 'package:buzi_kiosk/pages/processing_page.dart';
import 'package:flutter/material.dart';
import 'core/i18n.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    // Async processing status check after animation setup
    _checkProcessingStatusAsync();
  }
  Future<void> _checkProcessingStatusAsync() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('machines')
          .doc('M-0001')
          .get();
      final data = doc.data();
      final processing = data?['processing'] as Map<String, dynamic>?;
      if (processing?['isActive'] == true && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProcessingPage()),
          );
        });
      }
    } catch (e) {
      debugPrint('Async processing kontrolü hatası: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleStartPressed() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('machines')
          .doc('M-0001')
          .get();

      final data = doc.data();
      final isActive = data?['status']?['isActive'] ?? true;

      debugPrint('Firestore isActive: $isActive');

      if (!mounted) return;

      if (!isActive) {
        debugPrint('Makine kapalı, SalesClosedPage’e gidiliyor.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SalesClosedPage()),
        );
      } else if (isActive == true) {
        debugPrint('Makine aktif, ProductPage’e gidiliyor.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductPage()),
        );
      } else {
        debugPrint('isActive null veya okunamadı, SalesClosedPage’e gidiliyor.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SalesClosedPage()),
        );
      }
    } catch (e) {
      debugPrint('Firestore hata: $e');
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SalesClosedPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          final logoWidth = screenWidth * 0.35;
          final startButtonWidth = screenWidth * 0.16;
          final langButtonSize = screenWidth * 0.08;
          final bottomPadding = screenHeight * 0.05;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Arka plan
              Image.asset(
                'assets/wallpapers/wallpaper_empty.jpeg',
                fit: BoxFit.cover,
              ),

              // Sol üstteki dil değiştirme butonu
              Positioned(
                top: screenHeight * -0.05,
                left: screenWidth * 0.001,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      toggleLanguage();
                      setState(() {});
                    },
                    child: Image.asset(
                      'assets/buttons_new/lang_change.png',
                      width: langButtonSize,
                      height: langButtonSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Sağ üstteki ayarlar butonu
              Positioned(
                top: -25,
                right: 0,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AdminKeypadDialog(),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '⚙️',
                        style: TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ),
              ),

              // Ortadaki logo (breathing efekt)
              Center(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animation.value,
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/wallpapers/logo_final.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Alt ortadaki Başla butonu
              Positioned(
                bottom: bottomPadding,
                left: (screenWidth - startButtonWidth) / 2,
                child: GestureDetector(
                  onTap: _handleStartPressed,
                  child: Image.asset(
                    trEn('assets/buttons_new/start_tr.png', 'assets/buttons_new/start_en.png'),
                    width: startButtonWidth,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}