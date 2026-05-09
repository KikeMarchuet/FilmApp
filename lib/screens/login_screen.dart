import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../repositories/auth_repository.dart';
import '../state/app_state.dart';

class LoginScreen extends StatefulWidget {
  // Crea la pantalla de inicio de sesión.
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isRegisterMode = false;
  bool loading = false;
  String? errorKey;

  // Valida el formulario e intenta entrar o crear usuario.
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    if (isRegisterMode &&
        passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorKey = 'passwordMismatch';
      });
      return;
    }

    setState(() {
      loading = true;
      errorKey = null;
    });

    final appState = context.read<AppState>();
    final response = isRegisterMode
        ? await appState.register(
            userController.text,
            passwordController.text,
          )
        : await appState.login(
            userController.text,
            passwordController.text,
          );

    if (!mounted) return;
    setState(() {
      loading = false;
    });

    if (response.result == AuthResult.success) return;

    setState(() {
      errorKey = switch (response.result) {
        AuthResult.userAlreadyExists => 'userAlreadyExists',
        _ => 'invalidCredentials',
      };
    });
  }

  // Cambia entre entrar y crear usuario.
  void toggleMode() {
    setState(() {
      isRegisterMode = !isRegisterMode;
      errorKey = null;
      confirmPasswordController.clear();
    });
  }

  @override
  // Libera los controladores de texto.
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Muestra el formulario para entrar o crear usuario.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.text('appTitle')),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    isRegisterMode
                        ? l10n.text('createAccount')
                        : l10n.text('loginTitle'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.text('loginSubtitle')),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: userController,
                    decoration: InputDecoration(
                      labelText: l10n.text('userName'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? l10n.text('loginError')
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.text('password'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? l10n.text('loginError')
                        : null,
                  ),
                  if (isRegisterMode) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.text('confirmPassword'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_reset),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? l10n.text('loginError')
                          : null,
                      onFieldSubmitted: (_) => submit(),
                    ),
                  ],
                  if (errorKey != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.text(errorKey!),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: loading ? null : submit,
                    icon: Icon(isRegisterMode ? Icons.person_add : Icons.login),
                    label: Text(
                      isRegisterMode
                          ? l10n.text('createAccount')
                          : l10n.text('login'),
                    ),
                  ),
                  TextButton(
                    onPressed: loading ? null : toggleMode,
                    child: Text(
                      isRegisterMode
                          ? l10n.text('alreadyHaveAccount')
                          : l10n.text('createAccount'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
