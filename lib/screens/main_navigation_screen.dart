import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import 'add_pelicula_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  // Crea la pantalla con navegación inferior.
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  // Cambia la pestaña activa.
  void changeSection(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // Muestra las pestañas principales de la app.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    final user = appState.user!;
    final screens = [
      HomeScreen(
        key: ValueKey('movies-${user.id}'),
        user: user,
      ),
      HomeScreen(
        key: ValueKey('favorites-${user.id}'),
        user: user,
        onlyFavorites: true,
        showAddButton: false,
      ),
      AddPeliculaScreen(
        key: ValueKey('add-${user.id}'),
        user: user,
        closeAfterSave: false,
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: changeSection,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.movie_outlined),
            selectedIcon: const Icon(Icons.movie),
            label: l10n.text('movies'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.star_border),
            selectedIcon: const Icon(Icons.star),
            label: l10n.text('favorites'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_circle_outline),
            selectedIcon: const Icon(Icons.add_circle),
            label: l10n.text('add'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.text('settings'),
          ),
        ],
      ),
    );
  }
}
