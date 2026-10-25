import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tzikapp/services/teams_store.dart';

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
    expect(family.page, 0);
    expect(family.played, isEmpty);
    expect(teams.hasName('friends'), isTrue);
    expect(teams.hasName('Work'), isFalse);
  });

  test('keeps teams, places and played questions after a restart', () async {
    final teams = await TeamsStore.load();
    final friends = await teams.create('Friends');
    await teams.create('Family');
    await teams.setPage(friends, 4);
    await teams.togglePlayed(friends, 7);
    await teams.togglePlayed(friends, 9);
    await teams.togglePlayed(friends, 9);
    await teams.select(friends);

    final reloaded = await TeamsStore.load();
    expect(reloaded.teams.map((t) => t.name), ['Friends', 'Family']);
    expect(reloaded.selected?.name, 'Friends');
    expect(reloaded.selected?.page, 4);
    expect(reloaded.selected?.played, {7});
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
