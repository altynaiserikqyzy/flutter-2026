import 'package:flutter/material.dart';

import '../models/book_item.dart';
import '../models/profile.dart';
import '../navigation/routes.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state.dart';

class FavoritesScreen extends StatelessWidget {
  final List<BookItem> books;
  final Profile profile;
  final ValueChanged<BookItem> onUpdateBook;
  final ValueChanged<BookItem> onDeleteBook;
  final ValueChanged<int> onSwitchTab;

  const FavoritesScreen({
    super.key,
    required this.books,
    required this.profile,
    required this.onUpdateBook,
    required this.onDeleteBook,
    required this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {
    final favorites = books.where((book) => book.isFavorite).toList()
      ..sort((a, b) => a.when.compareTo(b.when));

    return Scaffold(
      appBar: AppBar(title: Text('Избранное (${favorites.length})')),
      body: favorites.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              message: 'Пока нет избранных книг',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: favorites.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final book = favorites[index];

                return BookCard(
                  book: book,
                  onTap: () {
                    Navigator.of(context).pushNamed<void>(
                      Routes.detail,
                      arguments: DetailRouteArgs(
                        book: book,
                        profile: profile,
                        onUpdate: onUpdateBook,
                        onDelete: onDeleteBook,
                        onSwitchTab: onSwitchTab,
                      ),
                    );
                  },
                  onFavoriteTap: () {
                    onUpdateBook(book.copyWith(isFavorite: false));
                  },
                );
              },
            ),
    );
  }
}
