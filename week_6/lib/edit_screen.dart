import 'package:flutter/material.dart';
import 'students.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key, required this.student});
  final Student student;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late final TextEditingController _controller;
  late final String _originalName;

  @override
  void initState() {
    super.initState();
    _originalName = widget.student.name;
    // Используем контроллер, чтобы имя сразу отображалось в текстовом поле
    _controller = TextEditingController(text: _originalName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isChanged => _controller.text != _originalName;

  Future<bool> _showDiscardDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isChanged,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await _showDiscardDialog();
        if (shouldPop && context.mounted) {
          // Важно: передаем null, так как пользователь отменил редактирование
          Navigator.of(context).pop(null); 
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Student Name'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  // Вызываем setState, чтобы PopScope узнал об изменении текста
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  // Возвращаем измененный текст обратно на DetailScreen
                  Navigator.of(context).pop(_controller.text);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
