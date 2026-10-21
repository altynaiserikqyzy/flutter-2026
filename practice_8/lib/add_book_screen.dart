import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    for (final c in [_title, _author, _pages, _year]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final book = Book(
        title: _title.text.trim(),
        author: _author.text.trim(),
        pages: int.parse(_pages.text),
        year: int.tryParse(_year.text),
      );
      Navigator.of(context).pop(book);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Title'),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (v) {
                  if ((v ?? '').trim().length < 2) return 'Title is too short';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _author,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Author'),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) return 'Author cannot be empty';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pages,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Pages'),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'A whole number above 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _year,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Year'),
                onFieldSubmitted: (_) => _save(),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (v) {
                  final text = v ?? '';
                  if (text.isEmpty) return null;
                  final n = int.tryParse(text);
                  final currentYear = DateTime.now().year;
                  if (n == null || n < 1450 || n > currentYear) {
                    return 'A number between 1450 and $currentYear';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
