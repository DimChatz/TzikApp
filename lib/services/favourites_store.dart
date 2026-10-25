import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Favourite questions, saved on the device, newest first.
///
/// Stores the question text itself, so favourites survive even if the
/// question is later edited or removed from `assets/questions.json`.
class FavouritesStore extends ChangeNotifier {
  FavouritesStore._(this._prefs, this._items);

  static const _key = 'favourites';

  final SharedPreferences _prefs;
  final List<String> _items;

  static Future<FavouritesStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    return FavouritesStore._(prefs, prefs.getStringList(_key) ?? []);
  }

  List<String> get items => List.unmodifiable(_items);

  bool contains(String text) => _items.contains(text);

  Future<void> add(String text, {int index = 0}) async {
    if (_items.contains(text)) return;
    _items.insert(index.clamp(0, _items.length), text);
    notifyListeners();
    await _save();
  }

  Future<void> remove(String text) async {
    if (!_items.remove(text)) return;
    notifyListeners();
    await _save();
  }

  Future<void> toggle(String text) => contains(text) ? remove(text) : add(text);

  Future<void> _save() => _prefs.setStringList(_key, _items);
}
