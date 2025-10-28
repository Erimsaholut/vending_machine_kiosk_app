// SPDX-License-Identifier: MIT
// device_controller.dart — Buzlime akış kontrolcüsü (REV)
// Bu dosya mevcut API’lerle uyumlu kalır:
// - connect(), close(), run(BuzlimeFlow flow)
// - stepStream, telemetryStream, Telemetry modeli
// - CommandQueue + Cmd ile JSON satır gönderen altyapı

import 'dart:async';
import 'models.dart';
import 'command_queue.dart';
import 'usb_cdc.dart';

/// Ekranda gösterilen adımlar
enum PrepStep {
  idle,
  cup,        // M2/M3: F 4 sn → B 4 sn
  valveTemp,  // M1: B 3 sn → (TEMP izle 2/3 sn) → F 3 sn
  tof1,       // 15–25 cm
  water,      // Röle ON (300 mL: 6 sn / 400 mL: 8 sn)
  tof2,       // 15–25 cm
  doorOpen,   // DOOR OPEN (fallback: M4 F)
  takePrompt, // Bardak alındı mı? (TOF ≥ 20 cm bekle)
  doorClose,  // DOOR CLOSE (fallback: M4 B)
  done,
  error,
}

/// Boy seçimi
class BuzlimeFlow {
  final bool large; // false = 300 mL, true = 400 mL
  BuzlimeFlow({required this.large});
}

class DeviceController {
  // === Sabitler ===
  static const Duration kPoll           = Duration(milliseconds: 500);

  static const Duration kM2M3EachDir    = Duration(seconds: 4); // bardak motoru
  static const Duration kM1Move         = Duration(seconds: 3); // M1 B/F hareket süreleri
  static const Duration kM1Wait300      = Duration(seconds: 2);
  static const Duration kM1Wait400      = Duration(seconds: 3);

  static const Duration kRelayOn300     = Duration(seconds: 6);
  static const Duration kRelayOn400     = Duration(seconds: 8);

  static const double   kTofMin         = 15.0; // hem TOF1 hem TOF2 için
  static const double   kTofMax         = 25.0;
  static const double   kTakenTofThresh = 20.0; // bardak alınmış saymak için

  // === Yayınlar ===
  final stepStream      = StreamController<PrepStep>.broadcast();
  final telemetryStream = StreamController<Telemetry>.broadcast();
  final Telemetry telemetry = Telemetry();

  // === Transport / Kuyruk ===
  final UsbCdcTransport _transport;
  CommandQueue? _queue;
  bool _connected = false;

  DeviceController({int? vendorIdHint, int? productIdHint, int baudRate = 115200})
      : _transport = UsbCdcTransport(
    vendorIdHint: vendorIdHint ?? 0,
    productIdHint: productIdHint ?? 0,
    baudRate: baudRate,
  );

  Future<bool> connect() async {
    try {
      await _transport.open();
      _connected = true;
      return true;
    } catch (_) {
      _connected = false;
      return false;
    }
  }

  Future<void> close() async {
    try { _queue?.dispose(); } catch (_) {}
    try { await _transport.close(); } catch (_) {}
    _connected = false;
  }

  Future<void> _ensureQueue() async {
    _queue ??= CommandQueue(_transport);
  }

  // === Ortak gönderim (Arduino ok:true kontrolü) ===
  Future<Map<String, dynamic>> _send(Cmd cmd, {Duration timeout = const Duration(seconds: 5)}) async {
    await _ensureQueue();
    final resp = await _queue!.send(cmd, timeout: timeout);
    final err = _validateArduinoOk(resp);
    if (err != null) {
      throw _FlowError(err);
    }
    return resp;
  }

  String? _validateArduinoOk(Map<String, dynamic>? resp) {
    if (resp == null) return 'error-2';
    final ok = resp['ok'] == true;
    if (!ok) {
      // Arduino {"ok":false,"err":{"code":"...","msg":"..."}} döndürebilir
      final err = resp['err'];
      if (err is Map && err['code'] is String) {
        final code = (err['code'] as String);
        if (code.contains('initial_tof')) return 'error-1';
        if (code.contains('temp'))        return 'error-2';
        if (code.contains('final_tof'))   return 'error-3';
      }
      return 'error-2';
    }
    return null;
  }

  // === Donanım yardımcıları ===
  Future<void> _motor(String name, String dir) async {
    final cmd = Cmd(type: 'cmd', name: name, dir: dir, id: DateTime.now().microsecondsSinceEpoch.toString());
    await _send(cmd);
  }

  Future<void> _relay(bool on) async {
    final cmd = Cmd(type: 'cmd', name: 'RELAY', state: on ? 'ON' : 'OFF', id: DateTime.now().microsecondsSinceEpoch.toString());
    await _send(cmd);
  }

  Future<double> _readTof() async {
    final cmd = Cmd(type: 'read', name: 'TOF', id: DateTime.now().microsecondsSinceEpoch.toString());
    final resp = await _send(cmd);
    final data = (resp['resp'] as Map?) ?? {};
    final cm = (data['cm'] is num) ? (data['cm'] as num).toDouble() : double.nan;
    return cm;
  }

  Future<double?> _readTemp() async {
    final cmd = Cmd(type: 'read', name: 'TEMP', id: DateTime.now().microsecondsSinceEpoch.toString());
    final resp = await _send(cmd);
    final data = (resp['resp'] as Map?) ?? {};
    final t = (data['tempC'] is num) ? (data['tempC'] as num).toDouble() : null;
    return t;
  }

  Future<void> _doorOpen() async {
    try {
      final cmd = Cmd(type: 'cmd', name: 'DOOR', dir: 'OPEN', id: DateTime.now().microsecondsSinceEpoch.toString());
      await _send(cmd);
    } catch (_) {
      await _motor('M4', 'F'); // fallback
    }
  }

  Future<void> _doorClose() async {
    try {
      final cmd = Cmd(type: 'cmd', name: 'DOOR', dir: 'CLOSE', id: DateTime.now().microsecondsSinceEpoch.toString());
      await _send(cmd);
    } catch (_) {
      await _motor('M4', 'B'); // fallback
    }
  }

  // === Kamu API ===
  Future<void> run(BuzlimeFlow flow) async {
    if (!_connected) throw _FlowError('error-2');

    try {
      // 1) CUP: sadece seçilen bardağın motoru (küçük= M2, büyük= M3)
      stepStream.add(PrepStep.cup);
      final String cupMotor = flow.large ? 'M3' : 'M2';
      await _motor(cupMotor, 'F'); await Future.delayed(kM2M3EachDir);
      await _motor(cupMotor, 'B'); await Future.delayed(kM2M3EachDir);

      // 2) VALVE + TEMP: M1 B 3 sn → bekle (TEMP izle) → M1 F 3 sn
      stepStream.add(PrepStep.valveTemp);
      await _motor('M1', 'B');
      {
        final t0 = DateTime.now();
        // B yönünde 3 sn sür
        while (DateTime.now().difference(t0) < kM1Move) {
          await Future.delayed(kPoll);
        }
        // Bekleme boyunca TEMP izle (300 mL: 2 sn / 400 mL: 3 sn)
        final waitDur = flow.large ? kM1Wait400 : kM1Wait300;
        final w0 = DateTime.now();
        while (DateTime.now().difference(w0) < waitDur) {
          await Future.delayed(kPoll);
          telemetry.tempC = await _readTemp();
          telemetryStream.add(telemetry);
        }
      }
      await _motor('M1', 'F');
      {
        final t0 = DateTime.now();
        while (DateTime.now().difference(t0) < kM1Move) {
          await Future.delayed(kPoll);
          // Bu sırada TEMP okumaya gerek yok
        }
      }

      // 3) TOF1: 15–25 cm
      stepStream.add(PrepStep.tof1);
      {
        final d = await _readTof();
        telemetry.tofCm = d; telemetryStream.add(telemetry);
        if (d.isNaN || d < kTofMin || d > kTofMax) {
          throw _FlowError('initial_tof');
        }
      }

      // 4) WATER: Röle ON 6/8 sn (TEMP izlemez)
      stepStream.add(PrepStep.water);
      await _relay(true);
      await Future.delayed(flow.large ? kRelayOn400 : kRelayOn300);
      await _relay(false);

      // 5) TOF2: 15–25 cm
      stepStream.add(PrepStep.tof2);
      {
        final d = await _readTof();
        telemetry.tofCm = d; telemetryStream.add(telemetry);
        if (d.isNaN || d < kTofMin || d > kTofMax) {
          throw _FlowError('final_tof');
        }
      }

      // 6) Kapı aç
      stepStream.add(PrepStep.doorOpen);
      await _doorOpen();

      // 7) Bardak alındı mı? (TOF ≥ 20 cm) — sınırsız bekle
      stepStream.add(PrepStep.takePrompt);
      while (true) {
        await Future.delayed(kPoll);
        final d = await _readTof();
        telemetry.tofCm = d; telemetryStream.add(telemetry);
        if (!d.isNaN && d >= kTakenTofThresh) break;
      }

      // 8) Kapı kapa
      stepStream.add(PrepStep.doorClose);
      await _doorClose();

      // 9) Bitti
      stepStream.add(PrepStep.done);
    } catch (e) {
      telemetry.lastError = e.toString();
      telemetryStream.add(telemetry);
      stepStream.add(PrepStep.error);
      rethrow;
    }
  }
}

/// Sadece hata kodu taşımak için
class _FlowError implements Exception {
  final String code;
  _FlowError(this.code);
  @override
  String toString() => code;
}
