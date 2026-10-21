import 'package:flutter/material.dart';

enum BookGenre {
  fantasy('Fantasy', Icons.auto_stories),
  detective('Detective', Icons.content_paste_search),
  science('Science', Icons.science),
  business('Business', Icons.business_center),
  tech('Tech', Icons.computer);

  final String label;
  final IconData icon;

  const BookGenre(this.label, this.icon);

  Color getRoleColor(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return switch (this) {
      BookGenre.fantasy => theme.primaryContainer,
      BookGenre.detective => theme.secondaryContainer,
      BookGenre.science => theme.tertiaryContainer,
      BookGenre.business => theme.surfaceContainerHighest,
      BookGenre.tech => theme.errorContainer,
    };
  }
}

sealed class Countdown {
  const Countdown();
}

class Upcoming extends Countdown {
  final Duration timeLeft;
  const Upcoming(this.timeLeft);
}

class Started extends Countdown {
  final Duration timePassed;
  const Started(this.timePassed);
}

class Ended extends Countdown {
  const Ended();
}

@immutable
class BookItem {
  final String id;
  final String title;
  final BookGenre genre;
  final DateTime when;
  final int limit;
  final List<String> readers;
  final bool isOnline;
  final String place;
  final String? description;
  final bool isFavorite;

  factory BookItem({
    required String id,
    required String title,
    required BookGenre genre,
    required DateTime when,
    required int limit,
    required List<String> readers,
    required bool isOnline,
    required String place,
    String? description,
    bool isFavorite = false,
  }) {
    return BookItem._(
      id: id,
      title: title,
      genre: genre,
      when: when,
      limit: limit,
      readers: List.unmodifiable(readers),
      isOnline: isOnline,
      place: place,
      description: description,
      isFavorite: isFavorite,
    );
  }

  const BookItem._({
    required this.id,
    required this.title,
    required this.genre,
    required this.when,
    required this.limit,
    required this.readers,
    required this.isOnline,
    required this.place,
    this.description,
    this.isFavorite = false,
  });
  BookItem.empty()
    : id = '',
      title = '',
      genre = BookGenre.fantasy,
      when = DateTime.now().add(const Duration(days: 1)),
      limit = 5,
      readers = const [],
      isOnline = false,
      place = '',
      description = null,
      isFavorite = false;
  int get count => readers.length;
  bool get isFull => count >= limit;
  bool get isPast => when.isBefore(DateTime.now());
  int get freePlaces => limit - count;
  bool contains(String name) => readers.contains(name);
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Countdown get countdown {
    final now = DateTime.now();
    final end = when.add(const Duration(hours: 2));
    if (now.isBefore(when)) {
      return Upcoming(when.difference(now));
    }
    if (now.isBefore(end)) {
      return Started(now.difference(when));
    }
    return const Ended();
  }

  BookItem copyWith({
    String? title,
    BookGenre? genre,
    DateTime? when,
    int? limit,
    List<String>? readers,
    bool? isOnline,
    String? place,
    Object? description,
    bool? isFavorite,
  }) {
    return BookItem(
      id: id,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      when: when ?? this.when,
      limit: limit ?? this.limit,
      readers: readers ?? List.unmodifiable(this.readers),
      isOnline: isOnline ?? this.isOnline,
      place: place ?? this.place,
      description: description == null
          ? this.description
          : description as String?,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
