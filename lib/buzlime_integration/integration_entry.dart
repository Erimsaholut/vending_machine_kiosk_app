// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import 'device_controller.dart';

/// PaymentPage'den çağrılan tek giriş.
/// 'done' veya 'error' döner.
Future<String> startBuzlimeFlow(BuildContext context, {required bool large}) async {
  final dev = DeviceController();

  final ok = await dev.connect();
  if (!ok) {
    // USB bağlanamadı → doğrudan error
    return 'error';
  }

  try {
    await dev.run(BuzlimeFlow(large: large));
    return 'done';
  } catch (_) {
    return 'error';
  } finally {
    await dev.close();
  }
}
