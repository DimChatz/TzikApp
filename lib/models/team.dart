import 'question.dart';

/// A group of friends playing together. Each team goes through the questions
/// on its own: it has its own place in the list and its own played questions.
///
/// Questions are remembered by their English text, not their number, so
/// reordering or renumbering `assets/questions.json` doesn't mix them up.
class Team {
  Team({
    required this.id,
    required this.name,
    this.question,
    this.page = 0,
    Set<String>? played,
  }) : played = played ?? {};

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json['id'] as String,
    name: json['name'] as String,
    question: json['question'] as String?,
    page: json['page'] as int? ?? 0,
    // Older versions saved played questions by number. Those numbers point at
    // other questions once the file is renumbered, so they are dropped.
    played: {...(json['played'] as List? ?? []).whereType<String>()},
  );

  final String id;
  final String name;

  /// The question the team left off at.
  String? question;

  /// Position in the question list where the team left off. Used when
  /// [question] is no longer in the list.
  int page;

  /// The questions the team marked as played.
  final Set<String> played;

  /// Where in [questions] the team left off.
  int pageIn(List<Question> questions) {
    final found = questions.indexWhere((q) => q.text == question);
    return found >= 0 ? found : page.clamp(0, questions.length - 1);
  }

  /// How many of [questions] the team has played. Questions removed from the
  /// list since don't count.
  int playedIn(List<Question> questions) =>
      questions.where((q) => played.contains(q.text)).length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'question': question,
    'page': page,
    'played': played.toList(),
  };
}
