import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String university;

  const ProfileHeader({required this.name, required this.university, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset('assets/images/avatar.jpg', width: 150, height: 150, fit: BoxFit.cover),
          ),
          const Padding(padding: EdgeInsets.only(top: 16.0)),
          Text(name, style: theme.textTheme.headlineMedium?.copyWith(fontFamily: 'CustomFont', color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          const Padding(padding: EdgeInsets.only(top: 8.0)),
          Text(university, textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.secondary)),
        ],
      ),
    );
  }
}
