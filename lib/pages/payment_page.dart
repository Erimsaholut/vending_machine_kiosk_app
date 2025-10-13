import '../widgets/background_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pages/test_refund_page.dart';
import 'preparing_page.dart';
import '../core/i18n.dart';

class PaymentPage extends StatelessWidget {
  final String title;
  final String volume;
  final String price;
  final int prepSeconds;
  final String drinkType;

  const PaymentPage({
    super.key,
    required this.title,
    required this.volume,
    required this.price,
    required this.prepSeconds,
  }) : drinkType = title;

  @override
  Widget build(BuildContext context) {
    final displayName = title == 'smallCup'
        ? trEn('Küçük Boy', 'Small Cup')
        : trEn('Büyük Boy', 'Large Cup');

    return BackgroundScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${trEn('Ödeme', 'Payment')} – $displayName $volume $price'),
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
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.08,
          ),
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
                        title: drinkType,
                        volume: volume,
                        price: price,
                        seconds: prepSeconds,
                      ),
                    ),
                  );
                },
                child: Text(
                  trEn('Ödeme Yapıldı', 'Payment Completed'),
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
                    MaterialPageRoute(
                      builder: (_) => TestRefundPage(
                        title: drinkType,
                        volume: volume,
                        price: price,
                        seconds: prepSeconds,
                      ),
                    ),
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