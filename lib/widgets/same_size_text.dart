import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Text that takes as much room as its longest translation, so switching
/// language doesn't move or resize anything around it.
///
/// The text in the other languages is laid out too, but not shown.
class SameSizeText extends StatelessWidget {
  const SameSizeText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.alignment = Alignment.center,
  });

  /// Picks the text out of one language's texts.
  final String Function(AppLocalizations l10n) text;

  final TextStyle? style;
  final TextAlign? textAlign;

  /// Where the text sits when it's shorter than the longest translation.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final shown = Localizations.localeOf(context).languageCode;
    Text textIn(AppLocalizations l10n) =>
        Text(text(l10n), style: style, textAlign: textAlign);
    return Stack(
      alignment: alignment,
      children: [
        for (final locale in AppLocalizations.supportedLocales)
          if (locale.languageCode != shown)
            Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: textIn(lookupAppLocalizations(locale)),
            ),
        textIn(AppLocalizations.of(context)),
      ],
    );
  }
}
