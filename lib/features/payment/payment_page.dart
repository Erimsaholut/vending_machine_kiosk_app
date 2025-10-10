import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/i18n.dart';
import '../../core/sales_data.dart';
import '../preparing/preparing_page.dart';
import '../refund/refund_page.dart';
import '../../widgets/background_scaffold.dart';

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
    return BackgroundScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(trEn('Ödeme','Payment') + ' – $title $volume $price'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Image.asset(
                'assets/buttons/payment.png',
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(300, 65),
              ),
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
              child: Text(
                trEn('Ödeme Yapıldı','Payment Completed'),
                style: const TextStyle(fontSize: 26),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(300, 65),
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
              child: Text(
                trEn('Hata – İade', 'Error – Refund'),
                style: const TextStyle(fontSize: 26),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}