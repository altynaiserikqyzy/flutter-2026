import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String name;
  final String email;
  final String group;
  final String birthDate;

  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birthDate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tiles = [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Name'),
            subtitle: Text(name),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(email),
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Group'),
            subtitle: Text(group),
          ),
          ListTile(
            leading: const Icon(Icons.cake),
            title: const Text('Birth Date'),
            subtitle: Text(birthDate),
          ),
        ];

        if (constraints.maxWidth >= 600) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 4,
            children: tiles,
          );
        } else {
          return Column(mainAxisSize: MainAxisSize.min, children: tiles);
        }
      },
    );
  }
}
