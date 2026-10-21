import 'package:flutter/material.dart';

import '../models/book_item.dart';
import '../utils/format.dart';

class BookCard extends StatelessWidget {
  final BookItem book;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: book.genre.getRoleColor(context),
                    child: Icon(
                      book.genre.icon,
                      color: colors.onPrimaryContainer,
                      size: 28,
                    ),
                  ),
                  if (book.isFull || book.freePlaces <= 5)
                    Positioned(
                      top: -6,
                      left: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: book.isFull ? colors.error : colors.tertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          book.isFull ? 'FULL' : '${book.freePlaces} left',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: book.isFull
                                    ? colors.onError
                                    : colors.onTertiary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatBookDate(book.when),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${book.count}/${book.limit} читателей',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (book.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: book.isFavorite
                    ? 'Убрать из избранного'
                    : 'В избранное',
                onPressed: onFavoriteTap,
                icon: Icon(
                  book.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: book.isFavorite ? colors.error : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
