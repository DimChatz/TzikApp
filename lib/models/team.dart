/// A group of friends playing together. Each team goes through the questions
/// on its own: it has its own place in the list and its own played questions.
class Team {
  Team({required this.id, required this.name, this.page = 0, Set<int>? played})
    : played = played ?? {};

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json['id'] as String,
    name: json['name'] as String,
    page: json['page'] as int? ?? 0,
    played: {...(json['played'] as List? ?? []).cast<int>()},
  );

  final String id;
  final String name;

  /// Position in the question list where the team left off.
  int page;

  /// Indexes of the questions the team marked as played.
  final Set<int> played;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'page': page,
    'played': played.toList()..sort(),
  };
}
