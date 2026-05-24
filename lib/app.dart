import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/inicio_screen.dart';
import 'state/app_state.dart';
import 'utils/app_theme.dart';

class FilmApp extends StatefulWidget {
  // Crea el widget principal de la app
  const FilmApp({super.key});

  // Crea el estado interno de la app
  @override
  State<FilmApp> createState() => _FilmAppState();
}

class _FilmAppState extends State<FilmApp> {
  bool showSplash = true;

  // Oculta la pantalla inicial y muestra la app
  void finishSplash() {
    setState(() {
      showSplash = false;
    });
  }

  // Monta Provider, localización, tema y pantalla inicial
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'FilmApp',
            debugShowCheckedModeBanner: false,
            locale: appState.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme,
            home: showSplash
                ? InicioScreen(onFinished: finishSplash)
                : appState.isAuthenticated
                    ? const MainNavigationScreen()
                    : const LoginScreen(),
          );
        },
      ),
    );
  }
}
