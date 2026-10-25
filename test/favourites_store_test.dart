import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tzikapp/services/favourites_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('toggle adds newest first and removes', () async {
    final store = await FavouritesStore.load();
    await store.toggle('A?');
    await store.toggle('B?');
    expect(store.items, ['B?', 'A?']);

    await store.toggle('A?');
    expect(store.items, ['B?']);
    expect(store.contains('A?'), isFalse);
  });

  test('persists across app restarts', () async {
    final store = await FavouritesStore.load();
    await store.add('Kept?');

    final reloaded = await FavouritesStore.load();
    expect(reloaded.items, ['Kept?']);
  });

  test('undo puts an item back where it was', () async {
    final store = await FavouritesStore.load();
    for (final q in ['C?', 'B?', 'A?']) {
      await store.add(q);
    }
    await store.remove('B?');
    await store.add('B?', index: 1);
    expect(store.items, ['A?', 'B?', 'C?']);
  });

  test('notifies listeners on change', () async {
    final store = await FavouritesStore.load();
    var notified = 0;
    store.addListener(() => notified++);
    await store.add('X?');
    await store.add('X?'); // already there: no change
    await store.remove('X?');
    expect(notified, 2);
  });
}
