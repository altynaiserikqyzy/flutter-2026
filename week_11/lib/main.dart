import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/api/api_client.dart'; // also exports Client
import 'dev/dev_checks.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';

/// Composition root: the only file that creates the http Client.
/// Dev checks: flutter run --dart-define=DEV_CHECKS=true
Future<void> main() async {
  if (kDebugMode && const bool.fromEnvironment('DEV_CHECKS')) {
    await runDevChecks();
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final model = UsersModel(UserRepository(ApiClient(Client())));
        unawaited(model.load());
        return model;
      },
      child: const App(),
    ),
  );
}
