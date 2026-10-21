import 'package:flutter/material.dart';

import '../models/book_item.dart';
import '../models/profile.dart';
import '../navigation/routes.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state.dart';

class ListScreen extends StatefulWidget {
  final List<BookItem> books;
  final Profile profile;
  final bool showPast;
  final ValueChanged<BookItem> onUpdateBook;
  final ValueChanged<BookItem> onAddBook;
  final ValueChanged<BookItem> onDeleteBook;
  final ValueChanged<int> onSwitchTab;

  const ListScreen({
    super.key,
    required this.books,
    required this.profile,
    required this.showPast,
    required this.onUpdateBook,
    required this.onAddBook,
    required this.onDeleteBook,
    required this.onSwitchTab,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final TextEditingController _searchController = TextEditingController();
  BookGenre? _selectedGenre;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BookItem> get _filteredBooks {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = widget.books.where((book) {
      final matchesTitle = book.title.toLowerCase().contains(query);
      final matchesPlace = book.place.toLowerCase().contains(query);
      final matchesGenre =
          _selectedGenre == null || book.genre == _selectedGenre;
      final matchesPast = !widget.showPast || book.isPast;

      return (matchesTitle || matchesPlace) && matchesGenre && matchesPast;
    }).toList();

    filtered.sort((a, b) {
      if (a.isPast != b.isPast) {
        return a.isPast ? 1 : -1;
      }
      return a.when.compareTo(b.when);
    });

    return filtered;
  }

  Future<void> _openDetail(BookItem book) async {
    await Navigator.of(context).pushNamed<void>(
      Routes.detail,
      arguments: DetailRouteArgs(
        book: book,
        profile: widget.profile,
        onUpdate: widget.onUpdateBook,
        onDelete: widget.onDeleteBook,
        onSwitchTab: widget.onSwitchTab,
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openForm() async {
    final result = await Navigator.of(context)
        .pushNamed<BookItem>(Routes.form, arguments: const FormRouteArgs());

    if (!mounted) return;

    if (result != null) {
      widget.onAddBook(result);
    }
  }

  void _toggleFavorite(BookItem book) {
    widget.onUpdateBook(book.copyWith(isFavorite: !book.isFavorite));
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _selectedGenre = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final books = _filteredBooks;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Поиск книг и мест',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Очистить поиск и фильтры',
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                ChoiceChip(
                  label: const Text('Все'),
                  selected: _selectedGenre == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedGenre = null;
                    });
                  },
                ),
                for (final genre in BookGenre.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      avatar: Icon(genre.icon, size: 18),
                      label: Text(genre.label),
                      selected: _selectedGenre == genre,
                      onSelected: (_) {
                        setState(() {
                          _selectedGenre = _selectedGenre == genre
                              ? null
                              : genre;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: books.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    message: 'Ничего не найдено',
                    buttonText: 'Сбросить фильтры',
                    onPressed: _clearSearch,
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 600) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 360,
                                mainAxisExtent: 195,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            final book = books[index];
                            return BookCard(
                              book: book,
                              onTap: () => _openDetail(book),
                              onFavoriteTap: () {
                                _toggleFavorite(book);
                              },
                            );
                          },
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: books.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return BookCard(
                            book: book,
                            onTap: () => _openDetail(book),
                            onFavoriteTap: () {
                              _toggleFavorite(book);
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        tooltip: 'Добавить книгу',
        child: const Icon(Icons.add),
      ),
    );
  }
}
