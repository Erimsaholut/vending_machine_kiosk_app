import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/i18n.dart';
import '../payment/payment_page.dart';
import '../../core/sales_data.dart';
import '../../widgets/background_scaffold.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = SalesData.instance;
    return BackgroundScaffold(
      appBar: AppBar(title: Text(trEn('Ürün Seçimi', 'Product Selection'))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // küçük
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: data.smallCups > 0
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentPage(
                              title: trEn('Küçük Boy','Small'),
                              volume: '300ml',
                              price: '30₺',
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
                    colorFilter: data.smallCups > 0
                        ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                        : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                    child: Image.asset(
                      'assets/buttons/product.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                trEn('Küçük Boy','Small'),
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                '300ml - 30₺',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (data.smallCups <= 0)
                const Text('Stokta yok', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          // büyük
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: data.largeCups > 0
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentPage(
                              title: trEn('Büyük Boy','Large'),
                              volume: '400ml',
                              price: '45₺',
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
                    colorFilter: data.largeCups > 0
                        ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                        : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                    child: Image.asset(
                      'assets/buttons/product.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                trEn('Büyük Boy','Large'),
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                '400ml - 45₺',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (data.largeCups <= 0)
                const Text('Stokta yok', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}