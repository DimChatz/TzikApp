import 'dart:convert';

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

/// Parses the questions file, returning the questions sorted by index.
///
/// Throws a [FormatException] that says what is wrong, so a hand edit that
/// breaks the file is easy to track down.
List<Question> parseQuestions(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! List) {
    throw const FormatException(
      'The questions file must be a list: [ {"index": 1, "text": "..."}, ... ]',
    );
  }

  final questions = <Question>[];
  final indexes = <int>{};
  for (var i = 0; i < decoded.length; i++) {
    final entry = decoded[i];
    final index = entry is Map ? entry['index'] : null;
    final text = entry is Map ? entry['text'] : null;
    final greekText = entry is Map ? entry['text_el'] : null;
    if (index is! int || index < 1) {
      throw FormatException(
        'Question #${i + 1} in the file needs an "index": a whole number '
        'from 1 up.',
      );
    }
    if (!indexes.add(index)) {
      throw FormatException('More than one question has "index": $index.');
    }
    if (text is! String || text.trim().isEmpty) {
      throw FormatException(
        'Question #${i + 1} in the file needs a non-empty "text".',
      );
    }
    if (greekText != null && greekText is! String) {
      throw FormatException(
        'Question #${i + 1} in the file has a "text_el" that is not text.',
      );
    }
    // A question without a Greek version, or with an empty one, is shown in
    // English.
    questions.add(
      Question(
        index: index,
        text: text.trim(),
        greekText: greekText is String && greekText.trim().isNotEmpty
            ? greekText.trim()
            : null,
      ),
    );
  }

  if (questions.isEmpty) {
    throw const FormatException('The questions file has no questions.');
  }
  return questions..sort((a, b) => a.index.compareTo(b.index));
}
