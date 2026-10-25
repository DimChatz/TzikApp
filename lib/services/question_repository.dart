import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/question.dart';

const questionsAsset = 'assets/questions.json';

const _cacheKey = 'downloaded_questions';

/// Loads the newest questions available: downloaded from [url] when online,
/// else the last downloaded copy, else the copy built into the app.
///
/// A downloaded file that doesn't parse is ignored, so a bad edit to the
/// online file can't break the app.
Future<List<Question>> loadQuestions(
  AssetBundle bundle, {
  String url = questionsUrl,
  http.Client? client,
}) async {
  if (url.isNotEmpty) {
    final prefs = await SharedPreferences.getInstance();
    final downloaded = await _download(url, client);
    final fromDownload = _tryParse(downloaded, 'downloaded');
    if (fromDownload != null) {
      await prefs.setString(_cacheKey, downloaded!);
      return fromDownload;
    }
    final fromCache = _tryParse(prefs.getString(_cacheKey), 'saved');
    if (fromCache != null) return fromCache;
  }
  return parseQuestions(await bundle.loadString(questionsAsset));
}

Future<String?> _download(String url, http.Client? injected) async {
  final client = injected ?? http.Client();
  try {
    final response = await client
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) return utf8.decode(response.bodyBytes);
    debugPrint('Downloading questions failed: HTTP ${response.statusCode}');
  } on Exception catch (e) {
    debugPrint('Downloading questions failed: $e');
  } finally {
    if (injected == null) client.close();
  }
  return null;
}

List<Question>? _tryParse(String? source, String label) {
  if (source == null) return null;
  try {
    return parseQuestions(source);
  } on FormatException catch (e) {
    debugPrint('Ignoring $label questions: $e');
    return null;
  }
}

/// Parses the questions file.
///
/// Throws a [FormatException] that says what is wrong, so a hand edit that
/// breaks the file is easy to track down.
List<Question> parseQuestions(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! List) {
    throw const FormatException(
      'The questions file must be a list: [ {"text": "..."}, ... ]',
    );
  }

  final questions = <Question>[];
  for (var i = 0; i < decoded.length; i++) {
    final entry = decoded[i];
    final text = entry is Map ? entry['text'] : null;
    if (text is! String || text.trim().isEmpty) {
      throw FormatException('Question #${i + 1} needs a non-empty "text".');
    }
    questions.add(Question(text: text.trim()));
  }

  if (questions.isEmpty) {
    throw const FormatException('The questions file has no questions.');
  }
  return questions;
}

/// Deals questions in random order, going through all of them before any
/// question repeats.
class QuestionDeck {
  QuestionDeck(List<Question> questions, {Random? random})
    : assert(questions.isNotEmpty),
      _questions = List.unmodifiable(questions),
      _random = random ?? Random();

  final List<Question> _questions;
  final Random _random;
  final List<Question> _pile = [];
  Question? _last;

  Question next() {
    if (_pile.isEmpty) {
      _pile
        ..addAll(_questions)
        ..shuffle(_random);
      // Don't show the same question twice in a row across a reshuffle.
      if (_pile.length > 1 && identical(_pile.last, _last)) {
        _pile.last = _pile.first;
        _pile.first = _last!;
      }
    }
    return _last = _pile.removeLast();
  }
}
