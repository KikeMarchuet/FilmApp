import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/pelicula.dart';
import '../state/app_state.dart';

class AddPeliculaScreen extends StatefulWidget {
  final AppUser? user;
  final bool closeAfterSave;

  // Crea la pantalla para añadir una película.
  const AddPeliculaScreen({
    super.key,
    this.user,
    this.closeAfterSave = true,
  });

  @override
  State<AddPeliculaScreen> createState() => _AddPeliculaScreenState();
}

class _AddPeliculaScreenState extends State<AddPeliculaScreen> {
  final _formKey = GlobalKey<FormState>();

  final tituloController = TextEditingController();
  final directorController = TextEditingController();
  final anioController = TextEditingController();
  final generoController = TextEditingController();
  final sinopsisController = TextEditingController();
  final caratulaController = TextEditingController();

  // Valida el formulario y guarda la película.
  Future<void> guardarPelicula() async {
    if (_formKey.currentState!.validate()) {
      final pelicula = Pelicula(
        titulo: tituloController.text.trim(),
        director: directorController.text.trim(),
        anio: int.parse(anioController.text.trim()),
        genero: generoController.text.trim(),
        sinopsis: sinopsisController.text.trim(),
        caratula: caratulaController.text.trim(),
      );

      await context.read<AppState>().addMovie(pelicula);

      if (!mounted) return;
      if (widget.closeAfterSave) {
        Navigator.pop(context);
        return;
      }

      _formKey.currentState!.reset();
      tituloController.clear();
      directorController.clear();
      anioController.clear();
      generoController.clear();
      sinopsisController.clear();
      caratulaController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).text('movieSaved'))),
      );
    }
  }

  // Libera los controladores de texto.
  @override
  void dispose() {
    tituloController.dispose();
    directorController.dispose();
    anioController.dispose();
    generoController.dispose();
    sinopsisController.dispose();
    caratulaController.dispose();
    super.dispose();
  }

  // Crea la decoración básica de un campo.
  InputDecoration deco(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }

  // Muestra el formulario para crear una película.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.text('newMovie')),
        actions: [
          if (widget.user != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.account_circle),
                  const SizedBox(width: 6),
                  Text(widget.user!.name),
                ],
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: tituloController,
                decoration: deco('Título'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Introduce el título'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: directorController,
                decoration: deco('Director'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Introduce el director'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: anioController,
                keyboardType: TextInputType.number,
                decoration: deco('Año'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Introduce el año';
                  if (int.tryParse(value) == null) return 'Debe ser numérico';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: generoController,
                decoration: deco('Género'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Introduce el género'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: sinopsisController,
                maxLines: 4,
                decoration: deco('Sinopsis'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Introduce la sinopsis'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: caratulaController,
                decoration: deco('Ruta de carátula (assets/images/...)'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Introduce la ruta de la carátula'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: guardarPelicula,
                child: const Text('Guardar película'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
