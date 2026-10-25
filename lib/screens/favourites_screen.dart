import 'package:flutter/material.dart';

import '../services/favourites_store.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key, required this.favourites});

  final FavouritesStore favourites;

  void _remove(BuildContext context, String text, int index) {
    favourites.remove(text);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Removed from favourites'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => favourites.add(text, index: index),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: ListenableBuilder(
        listenable: favourites,
        builder: (context, _) {
          final items = favourites.items;
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No favourites yet.\nTap the heart on a question to save it here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final text = items[index];
              return Dismissible(
                key: ValueKey(text),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _remove(context, text, index),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    title: Text(text),
                    trailing: IconButton(
                      tooltip: 'Remove from favourites',
                      onPressed: () => _remove(context, text, index),
                      icon: const Icon(Icons.favorite, color: Colors.pink),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
