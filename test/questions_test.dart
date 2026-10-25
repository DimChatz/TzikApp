import 'dart:io';
import 'dart:math';

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
    test('reads the text of each question, trimming whitespace', () {
      final questions = parseQuestions('''
        [
          {"text": "  First?  "},
          {"text": "Second?"}
        ]
      ''');
      expect(questions.map((q) => q.text), ['First?', 'Second?']);
    });

    test('rejects broken JSON', () {
      expect(
        () => parseQuestions('[{"text": "Missing quote}]'),
        throwsFormatException,
      );
    });

    test('rejects a file that is not a list', () {
      expect(() => parseQuestions('{"text": "Hi?"}'), throwsFormatException);
    });

    test('points at the entry with missing text', () {
      expect(
        () => parseQuestions('[{"text": "Ok?"}, {"txt": "Typo?"}]'),
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

  group('QuestionDeck', () {
    final questions = [for (var i = 0; i < 5; i++) Question(text: 'Q$i')];

    test('deals every question once before repeating', () {
      final deck = QuestionDeck(questions, random: Random(1));
      for (var round = 0; round < 3; round++) {
        final dealt = {for (var i = 0; i < 5; i++) deck.next().text};
        expect(dealt, hasLength(5));
      }
    });

    test('never deals the same question twice in a row', () {
      for (var seed = 0; seed < 50; seed++) {
        final deck = QuestionDeck(questions, random: Random(seed));
        var previous = deck.next();
        for (var i = 0; i < 20; i++) {
          final current = deck.next();
          expect(current, isNot(same(previous)), reason: 'seed $seed');
          previous = current;
        }
      }
    });

    test('works with a single question', () {
      final deck = QuestionDeck([const Question(text: 'Only?')]);
      expect(deck.next().text, 'Only?');
      expect(deck.next().text, 'Only?');
    });
  });
}
