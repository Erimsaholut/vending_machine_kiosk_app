import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import '../pages/test_refund_page.dart'; // test butonunu istersen debug'ta kullanırsın
import '../core/app_colors.dart';
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.bzPrimaryLight,
        elevation: 0,
        foregroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                isTurkish
                    ? 'assets/wallpapers/payment_tr.jpg'
                    : 'assets/wallpapers/payment_en.jpg',
              ),
              fit: BoxFit.cover,
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
                  // PRODUCTION: Ödeme başarıyla tamamlandığında PREPARING'e geç
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(300, 65),
                    ),
                    onPressed: () async {
                      Navigator.pushReplacement(
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

                  // (Opsiyonel) Test butonu: prod’da gizlemek için kDebugMode ile sarmalayabilirsiniz.
                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.red,
                  //     minimumSize: const Size(300, 65),
                  //   ),
                  //   onPressed: () {
                  //     Navigator.push(context, MaterialPageRoute(
                  //       builder: (_) => PreparingPage(
                  //         title: drinkType,
                  //         volume: volume,
                  //         price: price,
                  //         seconds: prepSeconds,
                  //       ),
                  //     ));
                  //   },
                  //   child: Text(
                  //     trEn('İade/Test', 'Refund/Test'),
                  //     style: const TextStyle(fontSize: 26),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
