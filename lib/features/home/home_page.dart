import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/i18n.dart';
import '../../widgets/admin_keypad_dialog.dart';
import '../product/product_page.dart';
import '../../core/sales_data.dart';

/// Wrap any screen with this to auto-return to home after [timeout] of no input.
class InactivityWrapper extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  const InactivityWrapper({
    super.key,
    required this.child,
    this.timeout = const Duration(seconds: 3),
  });

  @override
  State<InactivityWrapper> createState() => _InactivityWrapperState();
}

class _InactivityWrapperState extends State<InactivityWrapper> {
  Timer? _timer;

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeout, () {
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  void _onUserActivity([PointerEvent? _]) => _resetTimer();

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onUserActivity,
      onPointerMove: _onUserActivity,
      onPointerHover: _onUserActivity,
      onPointerSignal: _onUserActivity,
      child: widget.child,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return InactivityWrapper(
      timeout: const Duration(seconds: 30),
      child: AnimatedBuilder(
        animation: SalesData.instance,
        builder: (context, _) {
          final stock = SalesData.instance.totalStockMl;
          return Scaffold(
            body: Stack(
              children: [
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
                          SnackBar(content: Text(trEn('Girilen parola: $code','Entered code: $code'))),
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
                  child: Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[300],
                    child: const Center(child: Text("LOGO")),
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
                        backgroundColor: stock < 1000 ? Colors.red : null,
                      ),
                      onPressed: () {
                        if (stock < 400) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Scaffold(
                                appBar: AppBar(title: const Text('Bilgi')),
                                body: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      trEn(
                                        'Şu an yeterli stok bulunmamaktadır.\n'
                                        'En yakın zamanda stok yenilenecektir.\n'
                                        'İlginiz için teşekkür ederiz.',
                                        'Currently there is not enough stock.\n'
                                        'It will be renewed as soon as possible.\n'
                                        'Thank you for your understanding.',
                                      ),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProductPage()),
                          );
                        }
                      },
                      child: Text(trEn('Başla', 'Start')),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}