import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  // Crea la pantalla de configuración
  const SettingsScreen({super.key});

  // Muestra usuario, idioma y cierre de sesión
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    final user = appState.user!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.text('settingsTitle')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.account_circle),
                const SizedBox(width: 6),
                Text(user.name),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(l10n.text('account')),
            subtitle: Text(l10n.loggedInAs(user.name)),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.text('language')),
            subtitle: DropdownButton<Locale>(
              value: appState.locale,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: Locale('ca'),
                  child: Text('Valencià / Català'),
                ),
                DropdownMenuItem(
                  value: Locale('es'),
                  child: Text('Castellano'),
                ),
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
              ],
              onChanged: (newLocale) {
                if (newLocale != null) appState.changeLocale(newLocale);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.text('logout')),
            onTap: appState.logout,
          ),
        ],
      ),
    );
  }
}
