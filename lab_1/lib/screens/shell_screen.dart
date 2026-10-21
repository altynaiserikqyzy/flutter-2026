import 'package:flutter/material.dart';

import '../models/book_item.dart';
import '../models/profile.dart';
import 'list_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class ShellScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const ShellScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentTabIndex = 0;
  Profile _profile = Profile.empty();
  List<BookItem> _books = [];

  bool _showPastInList = false;

  @override
  void initState() {
    super.initState();
    _resetToSeedData();
  }

  void _resetToSeedData() {
    final now = DateTime.now();
    _profile = Profile.empty();
    _books = List.generate(
      12,
      (index) => BookItem(
        id: index.toString(),
        title: index == 0 ? 'A' * 60 : 'Книга №${index + 1}',
        genre: BookGenre.values[index % BookGenre.values.length],
        when: now.add(Duration(days: index - 2)),
        limit: index == 1 ? 2 : 10,
        readers: index == 1 ? ['Аня', 'Игорь'] : [],
        isOnline: index == 3,
        place: index == 3 ? 'https://zoom.us' : 'Библиотека, зал ${index + 1}',
        description: index == 2
            ? null
            : 'Встреча книжного клуба: обсуждение книги и обмен впечатлениями.',
      ),
    );
    _showPastInList = false;
  }

  void _handleUpdateBook(BookItem updatedBook) {
    setState(() {
      _books = _books
          .map((book) => book.id == updatedBook.id ? updatedBook : book)
          .toList();
    });
  }

  void _handleUpdateProfile(Profile updatedProfile) {
    setState(() {
      _profile = updatedProfile;
    });
  }

  void _handleAddBook(BookItem newBook) {
    setState(() {
      _books = [..._books, newBook];
    });
  }

  void _handleDeleteBook(BookItem bookToDelete) {
    setState(() {
      _books = _books.where((book) => book.id != bookToDelete.id).toList();
    });
  }

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('О программе'),
          content: const Text(
            'Книжный клуб\nЛабораторная работа №1',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmation() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Сбросить данные?'),
          content: const Text(
            'Все изменения будут отменены. '
            'Книги и профиль вернутся к исходным значениям.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  _resetToSeedData();
                });
              },
              child: const Text('Сбросить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final tabs = [
      ListScreen(
        books: _books,
        profile: _profile,
        showPast: _showPastInList,
        onUpdateBook: _handleUpdateBook,
        onAddBook: _handleAddBook,
        onDeleteBook: _handleDeleteBook,
        onSwitchTab: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
      ),
      FavoritesScreen(
        books: _books,
        profile: _profile,
        onUpdateBook: _handleUpdateBook,
        onDeleteBook: _handleDeleteBook,
        onSwitchTab: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
      ),
      ProfileScreen(
        profile: _profile,
        books: _books,
        currentThemeMode: widget.currentThemeMode,
        onProfileChanged: _handleUpdateProfile,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentTabIndex == 0
              ? 'Книжный клуб'
              : _currentTabIndex == 1
              ? 'Избранное'
              : 'Профиль',
        ),
        actions: [
          if (_currentTabIndex == 0)
            IconButton(
              tooltip: _showPastInList
                  ? 'Показать все встречи'
                  : 'Показать прошедшие встречи',
              onPressed: () {
                setState(() {
                  _showPastInList = !_showPastInList;
                });
              },
              icon: Icon(
                _showPastInList ? Icons.history : Icons.history_outlined,
              ),
            ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: colors.primaryContainer),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 42,
                      color: colors.onPrimaryContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Место для историй',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('О программе'),
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Сбросить данные'),
                onTap: () {
                  Navigator.pop(context);
                  _showResetConfirmation();
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(child: tabs[_currentTabIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_stories), label: 'Книги'),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Избранное',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
