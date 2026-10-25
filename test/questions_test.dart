import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tzikapp/models/question.dart';
import 'package:tzikapp/services/question_repository.dart';

void main() {
  // Run `flutter test` after editing assets/questions.json to catch mistakes
  // before they reach the app.
  group('assets/questions.json', () {
    late List<Question> questions;

    setUpAll(() {
      questions = parseQuestions(File(questionsAsset).readAsStringSync());
    });

    test('is valid and not empty', () {
      expect(questions, isNotEmpty);
    });

    test('has no duplicate questions', () {
      final seen = <String>{};
      final duplicates = [
        for (final q in questions)
          if (!seen.add(q.text.toLowerCase())) q.text,
      ];
      expect(duplicates, isEmpty);
    });
  });

  group('parseQuestions', () {
    test('reads each question, trimming whitespace, sorted by index', () {
      final questions = parseQuestions('''
        [
          {"index": 3, "text": "Third?"},
          {"index": 1, "text": "  First?  "},
          {"index": 2, "text": "Second?"}
        ]
      ''');
      expect(questions.map((q) => q.text), ['First?', 'Second?', 'Third?']);
      expect(questions.map((q) => q.index), [1, 2, 3]);
    });

    test('allows gaps in the numbering', () {
      final questions = parseQuestions(
        '[{"index": 1, "text": "A?"}, {"index": 5, "text": "B?"}]',
      );
      expect(questions.map((q) => q.index), [1, 5]);
    });

    test('requires an index on every question', () {
      expect(
        () => parseQuestions('[{"index": 1, "text": "A?"}, {"text": "B?"}]'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf(contains('#2'), contains('"index"')),
          ),
        ),
      );
    });

    test('rejects indexes that are not whole numbers from 1 up', () {
      for (final index in ['0', '-1', '1.5', '"1"', 'null']) {
        expect(
          () => parseQuestions('[{"index": $index, "text": "A?"}]'),
          throwsFormatException,
          reason: index,
        );
      }
    });

    test('rejects a repeated index', () {
      expect(
        () => parseQuestions(
          '[{"index": 1, "text": "A?"}, {"index": 1, "text": "B?"}]',
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('"index": 1'),
          ),
        ),
      );
    });

    test('rejects broken JSON', () {
      expect(
        () => parseQuestions('[{"index": 1, "text": "Missing quote}]'),
        throwsFormatException,
      );
    });

    test('rejects a file that is not a list', () {
      expect(
        () => parseQuestions('{"index": 1, "text": "Hi?"}'),
        throwsFormatException,
      );
    });

    test('points at the entry with missing text', () {
      expect(
        () => parseQuestions(
          '[{"index": 1, "text": "Ok?"}, {"index": 2, "txt": "Typo?"}]',
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('#2'),
          ),
        ),
      );
    });

    test('rejects an empty list', () {
      expect(() => parseQuestions('[]'), throwsFormatException);
    });
  });
}
