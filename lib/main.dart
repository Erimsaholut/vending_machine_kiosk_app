import 'package:buzi_kiosk/pages/product_page.dart';
import 'package:buzi_kiosk/widgets/admin_keypad_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/i18n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return I18nRebuilder(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Buzi Kiosk',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          // Görseller ekran boyutuna göre ölçeklensin
          final logoWidth = screenWidth * 0.40; // ekranın %50'si kadar logo
          final startButtonWidth = screenWidth * 0.20; // %35'i kadar başla butonu
          final langButtonSize = screenWidth * 0.12; // %12'si kadar köşe butonu
          final bottomPadding = screenHeight * -0.05; // alt boşluk

          return Stack(
            fit: StackFit.expand,
            children: [
              // Arka plan
              Image.asset(
                'assets/wallpapers/wallpaper_empty.jpeg',
                fit: BoxFit.cover,
              ),

              // Sol üstteki dil butonu
              Positioned(
                top: screenHeight * -0.05,
                left: screenWidth * 0.001,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      debugPrint("Language change pressed");
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

              // Sağ üstteki ayarlar butonu (⚙️)
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AdminKeypadDialog(),
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

              // Ortadaki logo
              Center(
                child: Image.asset(
                  'assets/wallpapers/logo_final.png',
                  width: logoWidth,
                  fit: BoxFit.contain,
                ),
              ),

              // Alt ortadaki başla butonu
              Positioned(
                bottom: bottomPadding,
                left: (screenWidth - startButtonWidth) / 2,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProductPage()),
                    );
                  },
                  child: Image.asset(
                    'assets/buttons_new/start_tr.png',
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