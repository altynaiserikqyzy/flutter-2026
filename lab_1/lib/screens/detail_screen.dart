import 'dart:async';

import 'package:flutter/material.dart';

import '../models/book_item.dart';
import '../models/profile.dart';
import '../navigation/routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

class DetailScreen extends StatefulWidget {
  final DetailRouteArgs args;

  const DetailScreen({super.key, required this.args});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late BookItem _book;
  late Profile _profile;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _book = widget.args.book;
    _profile = widget.args.profile;

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;

      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _actionLabel {
    if (_book.contains(_profile.name.trim())) {
      return 'Отменить участие';
    }

    return 'Присоединиться';
  }

  Future<bool> _confirmAction(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Подтверждение'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Подтвердить'),
            ),
          ],
        );
      },
    );

    if (!mounted) return false;

    return result ?? false;
  }

  Future<void> _toggleParticipation() async {
    final name = _profile.name.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Сначала заполни профиль'),
          action: SnackBarAction(
            label: 'Профиль',
            onPressed: () {
              widget.args.onSwitchTab(2);
              Navigator.of(context).pop();
            },
          ),
        ),
      );

      return;
    }

    final alreadyJoined = _book.contains(name);

    if (!alreadyJoined && _book.isFull) return;

    final confirmed = await _confirmAction(
      alreadyJoined
          ? 'Отменить участие во встрече?'
          : 'Присоединиться к встрече?',
    );

    if (!mounted || !confirmed) return;

    final updatedReaders = List<String>.from(_book.readers);

    if (alreadyJoined) {
      updatedReaders.remove(name);
    } else {
      updatedReaders.add(name);
    }

    final updatedBook = _book.copyWith(readers: updatedReaders);

    setState(() {
      _book = updatedBook;
    });

    widget.args.onUpdate(updatedBook);
  }

  Future<void> _editBook() async {
    final result = await Navigator.of(context).pushNamed<BookItem>(
      Routes.form,
      arguments: FormRouteArgs(initialBook: _book, currentCount: _book.count),
    );

    if (!mounted || result == null) return;

    setState(() {
      _book = result;
    });

    widget.args.onUpdate(result);
  }

  Future<void> _deleteBook() async {
    final confirmed = await _confirmAction(
      'Удалить эту книгу и все связанные с ней данные?',
    );

    if (!mounted || !confirmed) return;

    widget.args.onDelete(_book);

    Navigator.of(context).pop();
  }

  String _countdownText() {
    return switch (_book.countdown) {
      Upcoming(timeLeft: final duration) =>
        'Начнётся через ${duration.inHours} ч '
            '${duration.inMinutes.remainder(60)} мин',
      Started(timePassed: final duration) => 'Идёт ${duration.inMinutes} мин',
      Ended() => 'Встреча завершена',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = _profile.name.trim();

    final isJoined = name.isNotEmpty && _book.contains(name);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('О встрече'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editBook();
                } else if (value == 'delete') {
                  _deleteBook();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                PopupMenuItem(value: 'delete', child: Text('Удалить')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/book_cover.jpg',
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return Container(
                      height: 190,
                      width: double.infinity,
                      color: colors.primaryContainer,
                      child: Icon(
                        Icons.menu_book,
                        size: 72,
                        color: colors.onPrimaryContainer,
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Chip(
                    avatar: Icon(_book.genre.icon),
                    label: Text(_book.genre.label),
                    backgroundColor: colors.surface,
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Chip(
                    label: Text(_countdownText()),
                    backgroundColor: colors.surface,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _book.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(formatBookDate(_book.when)),
                  const SizedBox(height: 4),
                  Text(_book.place),
                  const SizedBox(height: 8),
                  Text(
                    '${_book.count}/${_book.limit} читателей',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            TabBar(
              tabs: [
                const Tab(text: 'О встрече'),
                Tab(text: 'Читатели (${_book.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Описание',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_book.description != null)
                        Text(_book.description!)
                      else
                        const Text('Описание отсутствует'),
                      const SizedBox(height: 20),
                      Text('Свободных мест: ${_book.places.free}'),
                    ],
                  ),
                  _book.readers.isEmpty
                      ? const EmptyState(
                          icon: Icons.people_outline,
                          message: 'Пока никто не присоединился',
                        )
                      : ListView.builder(
                          itemCount: _book.readers.length,
                          itemBuilder: (context, index) {
                            final reader = _book.readers[index];
                            final isYou = name.isNotEmpty && reader == name;

                            return ListTile(
                              leading: CircleAvatar(
                                child: Icon(
                                  isYou ? Icons.person : Icons.person_outline,
                                ),
                              ),
                              title: Text(
                                isYou ? '$reader (You)' : reader,
                                style: isYou
                                    ? const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _book.isFull && !isJoined
                      ? null
                      : _toggleParticipation,
                  child: Text(
                    _book.isFull && !isJoined ? 'Мест нет' : _actionLabel,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
