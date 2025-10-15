import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/i18n.dart';
import 'payment_page.dart';
import '../widgets/background_scaffold.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  Future<Map<String, dynamic>?> _fetchMachineData() async {
    final snap = await FirebaseFirestore.instance.collection('machines').doc('M-0001').get();
    return snap.data();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchMachineData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        final machine = snapshot.data!;
        final inv = Map<String, dynamic>.from(machine['inventory'] ?? {});
        final levels = Map<String, dynamic>.from(machine['levels'] ?? {});
        final int smallCups = (inv['smallCups'] ?? 0);
        final int largeCups = (inv['largeCups'] ?? 0);
        final int liquid = (levels['liquid'] ?? 0);

        final bool canSellSmall = smallCups > 3;
        final bool canSellLarge = largeCups > 3;

        return BackgroundScaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              trEn('Ürün Seçimi', 'Product Selection'),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // küçük
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: canSellSmall ? 1.0 : 0.4,
                    child: InkWell(
                      onTap: canSellSmall
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PaymentPage(
                                    title: 'smallCup',
                                    volume: '300ml',
                                    price: '30',
                                    prepSeconds: 3,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: SizedBox(
                        width: 180,
                        height: 250,
                        child: ColorFiltered(
                          colorFilter: canSellSmall
                              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                              : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                          child: Image.asset(
                            'assets/buttons/product.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    trEn('Küçük Boy','Small'),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    '300ml - 30₺',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (!canSellSmall)
                    const Text('Stokta yok', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
              // büyük
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: canSellLarge ? 1.0 : 0.4,
                    child: InkWell(
                      onTap: canSellLarge
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PaymentPage(
                                    title: 'largeCup',
                                    volume: '400ml',
                                    price: '45',
                                    prepSeconds: 5,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: SizedBox(
                        width: 220,
                        height: 300,
                        child: ColorFiltered(
                          colorFilter: canSellLarge
                              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                              : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                          child: Image.asset(
                            'assets/buttons/product.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    trEn('Büyük Boy','Large'),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    '400ml - 45₺',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (!canSellLarge)
                    const Text('Stokta yok', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}