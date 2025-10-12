import 'package:buzi_kiosk/pages/refund_animation_page.dart';
import 'package:flutter/material.dart';
import '../core/sales_data.dart';
import '../core/error_codes.dart';

class TestRefundPage extends StatelessWidget {
  const TestRefundPage({super.key});

  Future<void> _logRefund(String code, BuildContext context, String msg) async {
    await SalesData().logRefund(
      isSmall: true,
      amountTl: 30.0,
      amountMl: 300,
      errorCode: code,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
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
                await _logRefund(
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
                await _logRefund(
                  RefundErrorCodes.cupDrop,
                  context,
                  'Cup Drop log added',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RefundAnimationPage()),
                );
              },
              child: const Text('Cup Drop Error'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _logRefund(
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