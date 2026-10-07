import 'package:flutter/material.dart';
import 'contact_card.dart';
import 'contacts.dart';

class ContactList extends StatelessWidget {
  const ContactList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
          child: Text(
            '20 contacts',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: contacts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ContactCard(contact: contacts[index]);
            },
          ),
        ),
      ],
    );
  }
}
