import 'package:flutter/material.dart';
import 'data.dart';
import 'info_row.dart';
import 'profile_header.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile App',
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('My profile'), centerTitle: true),
        body: Center(
          child: Column(
            children: [
              const ProfileHeader(name: myName, university: myUniversity),
              const Padding(padding: EdgeInsets.only(top: 16.0)),
              ...facts.map((fact) => InfoRow(label: fact.label, value: fact.value)),
            ],
          ),
        ),
      ),
    );
  }
}
