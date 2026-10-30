import 'dart:ui';

/// One entry of `assets/questions.json`.
class Question {
  const Question({required this.index, required this.text, this.greekText});

  /// The question's number, counting from 1. Shown in the app and used to
  /// jump straight to the question.
  final int index;

  /// In English. Favourites are saved by this text, so they work in both
  /// languages.
  final String text;

  /// The `text_el` translation, if the question has one.
  final String? greekText;

  /// Greek when the app is in Greek and there is a translation, else English.
  String textFor(Locale locale) =>
      locale.languageCode == 'el' ? greekText ?? text : text;
}
