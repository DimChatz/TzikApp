import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/language_store.dart';
import '../theme.dart';
import 'same_size_text.dart';

/// 🌐 with the language the app is in (EN or ΕΛ). Tapping it switches to the
/// other one.
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key, required this.language});

  final LanguageStore language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Tooltip(
      message: l10n.switchLanguage,
      child: TextButton.icon(
        onPressed: language.toggle,
        style: TextButton.styleFrom(
          foregroundColor: brandNavy,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.language),
        label: SameSizeText((l10n) => l10n.languageCode),
      ),
    );
  }
}
