enum Genre {
  craft('craft'),
  theory('theory'),
  unknown('unknown');

  final String label;

  const Genre(this.label);

  static Genre fromString(String? raw) {
    switch (raw) {
      case 'craft':
        return Genre.craft;
      case 'theory':
        return Genre.theory;
      default:
        return Genre.unknown;
    }
  }
}

class Author {
  final String name;
  final String? country;

  const Author(this.name, this.country);

  @override
  String toString() {
    return country == null ? name : '$name ($country)';
  }
}

abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({
    required this.title,
    required this.year,
  });

  String describe();

  bool get isOld => year < 2000;
}

mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Borrow $title';
}

class Book extends LibraryItem with Borrowable {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  });

Book.missing()
    : pages = 0,
      author = const Author('Unknown', null),
      genre = Genre.unknown,
      description = null,
      super(
        title: 'Unknown title',
        year: 0,
      );

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] as String? ?? 'Unknown',
      year: json['year'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
      author: Author(
        json['author'] as String? ?? 'Unknown',
        json['country'] as String?,
      ),
      genre: Genre.fromString(json['genre'] as String?),
      description: json['description'] as String?,
    );
  }

  bool get isLong => pages > 400;

  @override
  String describe() {
    return 'Book: $title ($year), $pages pages';
  }

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) {
    return Book(
      title: title ?? this.title,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Book(title: $title, year: $year, pages: $pages, '
        'author: $author, genre: ${genre.label}, description: $description)';
  }
}

class Magazine extends LibraryItem with Borrowable {
  final int issues;

  const Magazine({
    required super.title,
    required super.year,
    required this.issues,
  });

  @override
  String describe() {
    return 'Magazine: $title, issues: $issues';
  }
}

class Ghost implements LibraryItem {
  @override
  final String title;

  @override
  final int year;

  const Ghost({
    required this.title,
    required this.year,
  });

  @override
  String describe() {
    return 'Ghost: $title ($year)';
  }

  @override
  bool get isOld => year < 2000;
}