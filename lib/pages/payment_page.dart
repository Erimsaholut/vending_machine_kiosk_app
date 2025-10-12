import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/i18n.dart';
import '../core/sales_data.dart';
import 'preparing_page.dart';
import 'refund_animation_page.dart';
import '../pages/test_refund_page.dart';
import '../widgets/background_scaffold.dart';

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
        title: Text('${trEn('Ödeme','Payment')} – $title $volume $price'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      ),
      child: SizedBox.expand(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                'assets/buttons/payment.png',
                fit: BoxFit.contain,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.5,
              ),
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(300, 65),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TestRefundPage()),
                  );
                },
                child: Text(
                  trEn('İade Sayfası', 'Refund Page'),
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