import 'package:flutter/material.dart';

import 'navigation/routes.dart';
import 'screens/shell_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final seedColor = ThemeData().colorScheme.primary;

    return MaterialApp(
      title: 'Reading Club App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      initialRoute: Routes.shell,
      onGenerateRoute: (settings) {
        if (settings.name == Routes.shell) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => ShellScreen(
              currentThemeMode: _themeMode,
              onThemeModeChanged: (newMode) {
                setState(() {
                  _themeMode = newMode;
                });
              },
            ),
          );
        }

        return generateAppRoute(settings);
      },
      onUnknownRoute: (_) {
        return MaterialPageRoute<void>(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Not found'))),
        );
      },
    );
  }
}
