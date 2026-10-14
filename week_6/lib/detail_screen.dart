import 'package:flutter/material.dart';
import 'students.dart';
import 'routes.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.student});
  final Student student;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Student _student;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

    Future<void> _edit() async {
    final name = await Navigator.of(context).pushNamed<String>(
      Routes.edit,
      arguments: _student, // Мы ОБЯЗАНЫ передать этот объект, иначе EditScreen откроется пустым!
    );
    
    if (name == null || !mounted) return;
    
    setState(() {
      _student = _student.copyWith(name: name);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_student.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _edit,
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Group'),
            subtitle: Text(_student.group),
          ),
          ListTile(
            leading: const Icon(Icons.mail),
            title: const Text('Email'),
            subtitle: Text(_student.email),
          ),
        ],
      ),
    );
  }
}
