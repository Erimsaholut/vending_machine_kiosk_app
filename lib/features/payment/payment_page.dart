import 'package:flutter/material.dart';
import '../../core/i18n.dart';
import '../../core/sales_data.dart';
import '../preparing/preparing_page.dart';
import '../refund/refund_page.dart';

class PaymentPage extends StatelessWidget {
  final String title;
  final String volume;
  final String price;
  final int prepSeconds;

  const PaymentPage({
    super.key,
    required this.title,
    required this.volume,
    required this.price,
    required this.prepSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(trEn('Ödeme','Payment') + ' – $title $volume $price')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200, height: 200,
              color: Colors.grey[300],
              child: Center(child: Text(trEn('Ödeme Resmi','Payment Image'))),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PreparingPage(
                      title: title,
                      volume: volume,
                      price: price,
                      seconds: prepSeconds,
                    ),
                  ),
                );
              },
              child: Text(trEn('Ödeme Yapıldı','Payment Completed')),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                // Register refund in SalesData
                final isSmall = volume.contains('300');
                final amount = isSmall ? 30.0 : 45.0;
                SalesData.instance.refund(
                  isSmall: isSmall,
                  amount: amount,
                  reason: "overfreeze",
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RefundPage()),
                );
              },
              child: Text(trEn('Hata – İade', 'Error – Refund')),
            ),
          ],
        ),
      ),
    );
  }
}