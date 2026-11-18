import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    final website = user.website;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          _row(Icons.badge_outlined, 'Username', '@${user.username}'),
          _row(Icons.email_outlined, 'Email', user.email),
          // taps do nothing yet — Practice 12 brings url_launcher
          _row(Icons.phone_outlined, 'Phone', user.phone, onTap: () {}),
          if (website != null)
            _row(Icons.language, 'Website', website, onTap: () {}),
          _row(
            Icons.home_outlined,
            'Address',
            '${a.street}, ${a.suite}\n${a.city}, ${a.zipcode}',
          ),
          _row(Icons.place_outlined, 'Geo', '${a.geo.lat}, ${a.geo.lng}'),
          _row(
            Icons.business_outlined,
            'Company',
            '${user.company.name}\n"${user.company.catchPhrase}"\n${user.company.bs}',
          ),
        ],
      ),
    );
  }

  Widget _row(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(value),
      subtitle: Text(label),
      onTap: onTap,
    );
  }
}
