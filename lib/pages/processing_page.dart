import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../core/app_colors.dart';
import '../core/i18n.dart';
import '../home_page.dart';
import 'package:buzi_kiosk/widgets/admin_keypad_dialog.dart';

class ProcessingPage extends StatefulWidget {
  const ProcessingPage({super.key});

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  Future<void> _startCountdown() async {
    final docRef = FirebaseFirestore.instance.collection('machines').doc('M-0001');
    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) return;

    final data = docSnapshot.data();
    if (data == null || !data.containsKey('processing') || !(data['processing'] is Map)) return;

    final processing = data['processing'] as Map<String, dynamic>;
    if (!processing.containsKey('until')) return;

    final Timestamp untilTimestamp = processing['until'];
    final until = untilTimestamp.toDate();
    _updateRemaining(until);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining(until);
    });
  }

  void _updateRemaining(DateTime until) {
    final now = DateTime.now();
    final diff = until.difference(now);
    if (diff.isNegative || diff == Duration.zero) {
      _timer?.cancel();
      // Firebase'de processing'i false yap
      FirebaseFirestore.instance
          .collection('machines')
          .doc('M-0001')
          .update({'processing.isActive': false});
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } else {
      setState(() {
        _remaining = diff;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight= MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenWidth * 0.18),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.bzPrimaryDark,
          leadingWidth: screenWidth * 0.1,
          leading: Padding(
            padding: const EdgeInsets.only(left: 2),
            child: GestureDetector(
              onTap: () {
                toggleLanguage();
                setState(() {});
              },
              child: Transform.scale(
                scale: 2, // Görseli %90 büyüt
                child: Image.asset(
                  'assets/buttons_new/lang_change.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 4),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AdminKeypadDialog(),
                  );
                },
                child: const Text(
                  '⚙️',
                  style: TextStyle(fontSize: 36),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isTurkish
                  ? 'assets/wallpapers/timer_tr.jpg'
                  : 'assets/wallpapers/timer_en.jpg',
              key: ValueKey(isTurkish),
              fit: BoxFit.cover,
            ),
          ),
          // timer circle
          Positioned(
            left: screenWidth * 0.4,
            top: screenHeight * 0.335,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 6),
                color: Colors.black26,
              ),
              alignment: Alignment.center,
              child: Text(
                _remaining == Duration.zero ? '' : _formatDuration(_remaining),
                style: const TextStyle(
                  fontSize: 64,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 43,
                      color: Colors.black54,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}