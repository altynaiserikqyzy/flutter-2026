import 'package:flutter/material.dart';

import '../models/book_item.dart';
import '../models/profile.dart';

class ProfileScreen extends StatefulWidget {
  final Profile profile;
  final List<BookItem> books;
  final ThemeMode currentThemeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const ProfileScreen({
    super.key,
    required this.profile,
    required this.books,
    required this.currentThemeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _groupController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.profile.name);

    _groupController = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.profile.name != widget.profile.name) {
      _nameController.text = widget.profile.name;
    }

    if (oldWidget.profile.group != widget.profile.group) {
      _groupController.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  int get _joinedCount {
    final name = widget.profile.name.trim();

    if (name.isEmpty) return 0;

    return widget.books.where((book) => book.contains(name)).length;
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() != true) return;

    final updatedProfile = widget.profile.copyWith(
      name: _nameController.text.trim(),
      group: _groupController.text.trim(),
    );

    widget.onProfileChanged(updatedProfile);
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите имя';
    }

    if (value.trim().length < 2) {
      return 'Имя должно содержать минимум 2 символа';
    }

    return null;
  }

  String? _validateGroup(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите группу';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: colors.primaryContainer,
            child: Icon(
              Icons.person,
              size: 48,
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.profile.name.isEmpty ? 'Твой профиль' : widget.profile.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (widget.profile.group.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Группа: ${widget.profile.group}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.outline),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Ты участвуешь в $_joinedCount встречах',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 28),
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  validator: _validateName,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _saveProfile(),
                  decoration: const InputDecoration(
                    labelText: 'Имя',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _groupController,
                  validator: _validateGroup,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _saveProfile(),
                  decoration: const InputDecoration(
                    labelText: 'Группа',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saveProfile,
                    child: const Text('Сохранить профиль'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Тема приложения',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Светлая'),
                selected: widget.currentThemeMode == ThemeMode.light,
                onSelected: (_) {
                  widget.onThemeModeChanged(ThemeMode.light);
                },
              ),
              ChoiceChip(
                label: const Text('Тёмная'),
                selected: widget.currentThemeMode == ThemeMode.dark,
                onSelected: (_) {
                  widget.onThemeModeChanged(ThemeMode.dark);
                },
              ),
              ChoiceChip(
                label: const Text('Системная'),
                selected: widget.currentThemeMode == ThemeMode.system,
                onSelected: (_) {
                  widget.onThemeModeChanged(ThemeMode.system);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
