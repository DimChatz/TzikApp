import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tzikapp/models/question.dart';
import 'package:tzikapp/services/teams_store.dart';

const _questions = [
  Question(index: 1, text: 'Cats?'),
  Question(index: 2, text: 'Dogs?'),
  Question(index: 3, text: 'Fish?'),
];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('starts with no teams', () async {
    final teams = await TeamsStore.load();
    expect(teams.teams, isEmpty);
    expect(teams.selected, isNull);
  });

  test('a new team is selected and starts from scratch', () async {
    final teams = await TeamsStore.load();
    await teams.create('  Friends ');
    final family = await teams.create('Family');
    expect(teams.selected, family);
    expect(family.pageIn(_questions), 0);
    expect(family.played, isEmpty);
    expect(teams.hasName('friends'), isTrue);
    expect(teams.hasName('Work'), isFalse);
  });

  test('keeps teams, places and played questions after a restart', () async {
    final teams = await TeamsStore.load();
    final friends = await teams.create('Friends');
    await teams.create('Family');
    await teams.setPlace(friends, 1, _questions[1]);
    await teams.togglePlayed(friends, _questions[0]);
    await teams.togglePlayed(friends, _questions[2]);
    await teams.togglePlayed(friends, _questions[2]);
    await teams.select(friends);

    final reloaded = await TeamsStore.load();
    expect(reloaded.teams.map((t) => t.name), ['Friends', 'Family']);
    final team = reloaded.selected!;
    expect(team.name, 'Friends');
    expect(team.pageIn(_questions), 1);
    expect(team.played, {'Cats?'});
    expect(team.playedIn(_questions), 1);
  });

  test('reordering the questions keeps place and played questions', () async {
    final teams = await TeamsStore.load();
    final friends = await teams.create('Friends');
    await teams.setPlace(friends, 1, _questions[1]);
    await teams.togglePlayed(friends, _questions[1]);

    final reordered = [_questions[2], _questions[0], _questions[1]];
    expect(friends.pageIn(reordered), 2);
    expect(friends.playedIn(reordered), 1);
  });

  test('a removed question no longer counts', () async {
    final teams = await TeamsStore.load();
    final friends = await teams.create('Friends');
    await teams.setPlace(friends, 1, _questions[1]);
    await teams.togglePlayed(friends, _questions[0]);
    await teams.togglePlayed(friends, _questions[1]);

    // The team was on the removed question, so it stays at the same position.
    final remaining = [_questions[0], _questions[2]];
    expect(friends.pageIn(remaining), 1);
    expect(friends.playedIn(remaining), 1);
  });

  test('drops played questions saved by number by older versions', () async {
    SharedPreferences.setMockInitialValues({
      'teams': '[{"id": "1", "name": "Friends", "page": 2, "played": [1, 3]}]',
    });
    final team = (await TeamsStore.load()).selected!;
    expect(team.played, isEmpty);
    expect(team.pageIn(_questions), 2);
  });

  test('deleting the selected team selects another', () async {
    final teams = await TeamsStore.load();
    final friends = await teams.create('Friends');
    final family = await teams.create('Family');
    await teams.delete(family);
    expect(teams.selected, friends);
    await teams.delete(friends);
    expect(teams.selected, isNull);
  });
}
