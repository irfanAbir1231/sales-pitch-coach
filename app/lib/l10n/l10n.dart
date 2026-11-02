import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  bool get isEnglish => Localizations.localeOf(this).languageCode == 'en';
}

/// Product categories come from the (Bangla) dataset; map them to the app language.
String localizedCategory(BuildContext context, String category) {
  final l = context.l10n;
  return switch (category) {
    'কাপড়ের যত্ন' => l.catFabric,
    'গরমের যত্ন' => l.catSummer,
    'ঘরের যত্ন' => l.catHome,
    'চুলের যত্ন' => l.catHair,
    'ত্বকের যত্ন' => l.catSkin,
    'দাঁতের যত্ন' => l.catOral,
    'নারীর যত্ন' => l.catFeminine,
    'পুরুষের যত্ন' => l.catMen,
    'বাবুর যত্ন' => l.catBaby,
    'স্বাস্থ্য' => l.catHealth,
    'স্বাস্থ্য সুরক্ষা' => l.catHealthProtection,
    _ => category,
  };
}

/// Shows digits in the app language: Bangla numerals in Bangla, Latin in English,
/// so a score like "8.5 / ১০" never mixes the two.
String localizeDigits(String text, BuildContext context) {
  if (context.isEnglish) return text;
  return text.replaceAllMapped(RegExp('[0-9]'), (m) => String.fromCharCode(0x09E6 + int.parse(m[0]!)));
}
