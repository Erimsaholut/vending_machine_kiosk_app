import 'package:flutter/material.dart';
import '../../core/i18n.dart';
import '../payment/payment_page.dart';
import '../../core/sales_data.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = SalesData.instance;
    return Scaffold(
      appBar: AppBar(title: Text(trEn('Ürün Seçimi', 'Product Selection'))),
      body: Row(
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
                child: Container(
                  width: 100, height: 150,
                  color: data.smallCups > 0 ? Colors.blue[100] : Colors.grey,
                  child: const Center(child: Text('Resim')),
                ),
              ),
              const SizedBox(height: 10),
              Text(trEn('Küçük Boy','Small')),
              const Text('300ml - 30₺'),
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
                child: Container(
                  width: 100, height: 150,
                  color: data.largeCups > 0 ? Colors.red[100] : Colors.grey,
                  child: const Center(child: Text('Resim')),
                ),
              ),
              const SizedBox(height: 10),
              Text(trEn('Büyük Boy','Large')),
              const Text('400ml - 45₺'),
              if (data.largeCups <= 0)
                const Text('Stokta yok', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}