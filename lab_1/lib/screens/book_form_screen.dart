import 'package:flutter/material.dart';

import '../models/book_item.dart';
import '../navigation/routes.dart';
import '../utils/format.dart';

class BookFormScreen extends StatefulWidget {
  final FormRouteArgs args;

  const BookFormScreen({super.key, required this.args});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _placeController;
  late final TextEditingController _limitController;
  late final TextEditingController _descriptionController;

  late final FocusNode _titleFocus;
  late final FocusNode _placeFocus;
  late final FocusNode _limitFocus;
  late final FocusNode _descriptionFocus;

  late BookGenre _genre;
  late DateTime _when;
  late bool _isOnline;
  late String? _description;

  bool _saving = false;
  bool _discardApproved = false;

  late final String _originalTitle;
  late final String _originalPlace;
  late final String _originalLimit;
  late final String _originalDescription;
  late final BookGenre _originalGenre;
  late final DateTime _originalWhen;
  late final bool _originalOnline;

  bool get _isEditing => widget.args.initialBook != null;

  BookItem get _initialBook => widget.args.initialBook ?? BookItem.empty();

  bool get _dirty {
    return _titleController.text != _originalTitle ||
        _placeController.text != _originalPlace ||
        _limitController.text != _originalLimit ||
        _descriptionController.text != _originalDescription ||
        _genre != _originalGenre ||
        _when != _originalWhen ||
        _isOnline != _originalOnline;
  }

  @override
  void initState() {
    super.initState();

    final book = _initialBook;

    _titleController = TextEditingController(text: book.title);
    _placeController = TextEditingController(text: book.place);
    _limitController = TextEditingController(text: book.limit.toString());
    _descriptionController = TextEditingController(
      text: book.description ?? '',
    );

    _titleFocus = FocusNode();
    _placeFocus = FocusNode();
    _limitFocus = FocusNode();
    _descriptionFocus = FocusNode();

    _genre = book.genre;
    _when = book.when;
    _isOnline = book.isOnline;
    _description = book.description;

    _originalTitle = _titleController.text;
    _originalPlace = _placeController.text;
    _originalLimit = _limitController.text;
    _originalDescription = _descriptionController.text;
    _originalGenre = _genre;
    _originalWhen = _when;
    _originalOnline = _isOnline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _limitController.dispose();
    _descriptionController.dispose();

    _titleFocus.dispose();
    _placeFocus.dispose();
    _limitFocus.dispose();
    _descriptionFocus.dispose();

    super.dispose();
  }

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';

    if (title.length < 3 || title.length > 60) {
      return 'Название должно содержать 3–60 символов';
    }

    return null;
  }

  String? _validatePlace(String? value) {
    final place = value?.trim() ?? '';

    if (place.isEmpty) {
      return 'Укажите место встречи';
    }

    if (_isOnline && !place.contains('://')) {
      return 'Укажите ссылку с ://';
    }

    return null;
  }

  String? _validateLimit(String? value) {
    final limit = int.tryParse(value ?? '');

    if (limit == null || limit < 1 || limit > 500) {
      return 'Введите число от 1 до 500';
    }

    if (_isEditing && limit < widget.args.currentCount) {
      return 'Лимит не может быть меньше числа читателей';
    }

    return null;
  }

  String? _validateDescription(String? value) {
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _when.isBefore(now) ? now : _when,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );

    if (!mounted) return;

    if (selected != null) {
      setState(() {
        _when = DateTime(
          selected.year,
          selected.month,
          selected.day,
          _when.hour,
          _when.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );

    if (!mounted) return;

    if (selected != null) {
      setState(() {
        _when = DateTime(
          _when.year,
          _when.month,
          _when.day,
          selected.hour,
          selected.minute,
        );
      });
    }
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Отменить изменения?'),
          content: const Text('Несохранённые изменения будут потеряны.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Продолжить редактирование'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Отменить изменения'),
            ),
          ],
        );
      },
    );

    if (!mounted) return false;

    return result ?? false;
  }

  Future<void> _handlePop(bool didPop, Object? result) async {
    if (didPop || !_dirty || _discardApproved || _saving) {
      return;
    }

    final discard = await _confirmDiscard();

    if (!mounted || !discard) return;

    setState(() {
      _discardApproved = true;
    });

    Navigator.of(context).pop();
  }

  Future<void> _save() async {
    if (_saving) return;

    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() != true) return;

    final now = DateTime.now();

    if (!_isEditing && !_when.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Для новой встречи выберите будущее время'),
        ),
      );
      return;
    }

    final limit = int.tryParse(_limitController.text);

    if (limit == null) return;

    final descriptionText = _descriptionController.text.trim();

    setState(() {
      _saving = true;
    });

    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final original = widget.args.initialBook;

    final result = BookItem(
      id: original?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      genre: _genre,
      when: _when,
      limit: limit,
      readers: original?.readers ?? const [],
      isOnline: _isOnline,
      place: _placeController.text.trim(),
      description: descriptionText.isEmpty ? null : descriptionText,
      isFavorite: original?.isFavorite ?? false,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopScope<Object?>(
      canPop: !_dirty || _discardApproved || _saving,
      onPopInvokedWithResult: _handlePop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Редактировать книгу' : 'Новая книга'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  maxLength: 60,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    _placeFocus.requestFocus();
                  },
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                  },
                  validator: _validateTitle,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<BookGenre>(
                  initialValue: _genre,
                  decoration: const InputDecoration(
                    labelText: 'Категория',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final genre in BookGenre.values)
                      DropdownMenuItem(
                        value: genre,
                        child: Row(
                          children: [
                            Icon(genre.icon),
                            const SizedBox(width: 8),
                            Text(genre.label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _genre = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Выберите категорию';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Онлайн-встреча'),
                  value: _isOnline,
                  onChanged: (value) {
                    setState(() {
                      _isOnline = value;
                    });

                    _formKey.currentState?.validate();
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _placeController,
                  focusNode: _placeFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    _limitFocus.requestFocus();
                  },
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                  },
                  validator: _validatePlace,
                  decoration: InputDecoration(
                    labelText: _isOnline
                        ? 'Ссылка на встречу'
                        : 'Место встречи',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _limitController,
                  focusNode: _limitFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    _descriptionFocus.requestFocus();
                  },
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                  },
                  validator: _validateLimit,
                  decoration: const InputDecoration(
                    labelText: 'Количество участников',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  focusNode: _descriptionFocus,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                  },
                  validator: _validateDescription,
                  decoration: const InputDecoration(
                    labelText: 'Описание (необязательно)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Дата и время',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          '${_when.day.toString().padLeft(2, '0')}.'
                          '${_when.month.toString().padLeft(2, '0')}.'
                          '${_when.year}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.access_time),
                        label: Text(formatBookDate(_when).split(', ').last),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
                          ),
                        )
                      : const Text('Сохранить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
