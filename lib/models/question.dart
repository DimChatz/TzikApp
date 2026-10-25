/// One entry of `assets/questions.json`.
class Question {
  const Question({required this.index, required this.text});

  /// The question's number, counting from 1. Shown in the app and used to
  /// jump straight to the question.
  final int index;

  final String text;
}
