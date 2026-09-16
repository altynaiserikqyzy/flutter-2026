import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  final books = rawBooks
      .map((json) => Book.fromJson(json))
      .toList();

  final library = Library();

  for (final book in books) {
    library.addItem(book);
  }

  library.open();

  print('Titles: ${library.titles}');
  print('Books after 2010: ${library.booksAfter2010}');
  print('Average pages: ${library.averagePages}');
  print('Books by author: ${library.booksByAuthor}');
  print('Author names: ${library.authorNames}');
  print('Genres: ${library.genres}');
  print('Display list:');
  for (final item in library.displayList) {
    print(item);
  }

  final stats = statsOf(books);

  print('Count: ${stats.count}');
  print('Average pages from record: ${stats.avgPages}');

  print(describe(Empty()));
  print(describe(Ready(books)));
  print(describe(Broken('Shelf needs repair')));
}