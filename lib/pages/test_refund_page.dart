import 'package:buzi_kiosk/pages/refund_animation_page.dart';
import 'package:flutter/material.dart';
import '../core/sales_data.dart';
import '../core/error_codes.dart';

class TestRefundPage extends StatelessWidget {
  final String title;
  final String volume;
  final String price;
  final int seconds;

  const TestRefundPage({
    super.key,
    required this.title,
    required this.volume,
    required this.price,
    required this.seconds,
  });

  Future<void> _logRefundAuto(String code, BuildContext context, String msg) async {
    final cupType = title;
    final amountTl = double.tryParse(price) ?? 0.0;
    final amountMl = int.tryParse(volume.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    await SalesData.instance.logRefund(
      amountTl: amountTl,
      amountMl: amountMl,
      errorCode: code,
      cupType: title,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$msg ($cupType)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Refunds'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _logRefundAuto(
                  RefundErrorCodes.overfreeze,
                  context,
                  'Overfreeze log added',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RefundAnimationPage()),
                );
              },
              child: const Text('Overfreeze Error'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _logRefundAuto(
                  RefundErrorCodes.cupDrop,
                  context,
                  'Cup Drop log added',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RefundAnimationPage()),
                );
              },
              child: const Text('Cup Drop'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _logRefundAuto(
                  RefundErrorCodes.other,
                  context,
                  'Other Error log added',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RefundAnimationPage()),
                );
              },
              child: const Text('Other Error'),
            ),
          ],
        ),
      ),
    );
  }
}