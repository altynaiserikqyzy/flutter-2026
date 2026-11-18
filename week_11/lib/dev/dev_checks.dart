import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../features/users/user.dart';
import '../features/users/user_repository.dart';

const _user1 = r'''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": { "lat": "-37.3159", "lng": "81.1496" }
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}
''';

/// Level 2 + Level 3 checks, run before runApp. No screen involved.
Future<void> runDevChecks() async {
  // Level 2: model
  final user = User.fromJson(jsonDecode(_user1) as Map<String, dynamic>);
  debugPrint('parsed: $user');
  debugPrint('phoneDigits: ${user.phoneDigits}');
  debugPrint('round-trip equal: ${User.fromJson(user.toJson()) == user}');

  // Level 3: repository
  final repo = UserRepository(ApiClient(Client()));
  final all = await repo.getAll();
  debugPrint('getAll: ${all.map((u) => u.name).toList()}');

  try {
    await repo.getById(999);
  } on NotFoundException {
    debugPrint('not found');
  }

  final created = await repo.create(
    const User(
      id: 0,
      name: 'Test User',
      username: 'test',
      email: 'test@example.com',
      phone: '',
      address: Address(
        street: '',
        suite: '',
        city: '',
        zipcode: '',
        geo: Geo(lat: 0, lng: 0),
      ),
      company: (name: '', catchPhrase: '', bs: ''),
    ),
  );
  debugPrint('created id: ${created.id}'); // 11
}
