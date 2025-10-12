import 'package:flutter/material.dart';

/// Seçilen dil (varsayılan Türkçe).
ValueNotifier<bool> isEnglish = ValueNotifier(false);

/// Türkçe – İngilizce çevirici
String trEn(String tr, String en) => isEnglish.value ? en : tr;

/// İngilizce – Türkçe çevirici
String enTr(String en, String tr) => isEnglish.value ? en : tr;

/// Dil değiştiğinde rebuild için kullanılacak widget
class I18nRebuilder extends StatelessWidget {
  final Widget child;
  const I18nRebuilder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isEnglish,
      builder: (context, _, __) => child,
    );
  }
}