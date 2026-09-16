import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  late final DateTime openedAt;

  String? _cachedReport;

  void addItem(LibraryItem item) {
    items.add(item);
  }

  Book? findBookByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }
    return null;
  }

  String countryOf(String title) {
    final book = findBookByTitle(title);
    return book?.author.country ?? 'Unknown';
  }

  void open() {
    openedAt = DateTime.now();
  }

  String _buildReport() {
    return _cachedReport ??= 'Library contains ${items.length} items';
  }

  List<String> get titles =>
      items.whereType<Book>().map((book) => book.title).toList();

  List<Book> get booksAfter2010 =>
      items.whereType<Book>().where((book) => book.year > 2010).toList();

  double get averagePages =>
      items.whereType<Book>().isEmpty
          ? 0
          : items.whereType<Book>().fold<int>(
                0,
                (sum, book) => sum + book.pages,
              ) /
              items.whereType<Book>().length;

  Map<String, int> get booksByAuthor =>
      items.whereType<Book>().fold<Map<String, int>>(
        {},
        (result, book) {
          result[book.author.name] =
              (result[book.author.name] ?? 0) + 1;
          return result;
        },
      );

  Set<String> get authorNames =>
      items.whereType<Book>().map((book) => book.author.name).toSet();

  Set<Genre> get genres =>
      items.whereType<Book>().map((book) => book.genre).toSet();

  List<String> get displayList => [
        'CATALOGUE',
        for (final book in items.whereType<Book>())
          '${book.title} (${book.year})',
        ...items
            .whereType<Book>()
            .map((book) => book.author.name),
        if (items.whereType<Book>().any((book) => book.pages == 0))
          '(incomplete data)',
      ];
}