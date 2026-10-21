import 'package:flutter/material.dart';

import '../models/book_item.dart';
import '../models/profile.dart';
import '../screens/book_form_screen.dart';
import '../screens/detail_screen.dart';

class Routes {
  static const String shell = '/';
  static const String detail = '/detail';
  static const String form = '/form';
}

class DetailRouteArgs {
  final BookItem book;
  final Profile profile;
  final ValueChanged<BookItem> onUpdate;
  final ValueChanged<BookItem> onDelete;
  final ValueChanged<int> onSwitchTab;

  const DetailRouteArgs({
    required this.book,
    required this.profile,
    required this.onUpdate,
    required this.onDelete,
    required this.onSwitchTab,
  });
}

class FormRouteArgs {
  final BookItem? initialBook;
  final int currentCount;

  const FormRouteArgs({this.initialBook, this.currentCount = 0});
}

Route<dynamic> generateAppRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.detail:
      final args = settings.arguments;

      if (args is! DetailRouteArgs) {
        return MaterialPageRoute<void>(builder: (_) => const _NotFoundScreen());
      }

      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => DetailScreen(args: args),
      );

    case Routes.form:
      final args = settings.arguments;

      if (args != null && args is! FormRouteArgs) {
        return MaterialPageRoute<void>(builder: (_) => const _NotFoundScreen());
      }

      final formArgs = args is FormRouteArgs ? args : const FormRouteArgs();

      return MaterialPageRoute<BookItem>(
        settings: settings,
        builder: (_) => BookFormScreen(args: formArgs),
      );

    default:
      return MaterialPageRoute<void>(builder: (_) => const _NotFoundScreen());
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Страница не найдена')),
      body: const Center(child: Text('Not found')),
    );
  }
}
