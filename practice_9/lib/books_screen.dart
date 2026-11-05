import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/book.dart';
import 'models/cart.dart';
import 'cart_badge.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Фильтрация списка на основе поискового запроса (Эфемерное состояние)
    final filteredBooks = books.where((book) {
      return book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final cartItems = context.watch<Cart>().items;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search books...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black54),
          ),
          style: const TextStyle(color: Colors.black),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: const [CartBadge(), SizedBox(width: 16)],
      ),
      body: ListView.builder(
        itemCount: filteredBooks.length,
        itemBuilder: (context, index) {
          final book = filteredBooks[index];
          final isInCart = cartItems.contains(book);

          return ListTile(
            title: Text(book.title),
            subtitle: Text(book.author),
            trailing: isInCart
                ? const Text(
                    'Added',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : OutlinedButton(
                    onPressed: () {
                      final ok = context.read<Cart>().add(book);
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added "${book.title}" to cart'),
                          ),
                        );
                      }
                    },
                    child: const Text('Add'),
                  ),
          );
        },
      ),
    );
  }
}
