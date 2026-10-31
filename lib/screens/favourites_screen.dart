import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/question.dart';
import '../services/favourites_store.dart';
import '../widgets/gradient_background.dart';
import '../widgets/same_size_text.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({
    super.key,
    required this.favourites,
    required this.questions,
  });

  final FavouritesStore favourites;

  /// To show favourites in Greek when the app is in Greek.
  final List<Question> questions;

  void _remove(BuildContext context, String text, int index) {
    final l10n = AppLocalizations.of(context);
    favourites.remove(text);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.removedFromFavourites),
          // A snack bar with an action otherwise stays up until it is tapped.
          persist: false,
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => favourites.add(text, index: index),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    // Favourites are saved by their English text.
    final byText = {for (final q in questions) q.text: q};
    // The Undo snack bar belongs to this screen, so it shouldn't follow you
    // back to the home screen.
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: GradientScaffold(
        appBar: AppBar(title: Text(l10n.favourites)),
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
                      SameSizeText(
                        (l10n) => l10n.noFavourites,
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
                      // A favourite whose question was since removed from
                      // the list is shown as it was saved.
                      title: Text(byText[text]?.textFor(locale) ?? text),
                      trailing: IconButton(
                        tooltip: l10n.removeFromFavourites,
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
      ),
    );
  }
}
