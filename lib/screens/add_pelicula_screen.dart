import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/pelicula.dart';
import '../services/firebase_service.dart';
import '../state/app_state.dart';

class AddPeliculaScreen extends StatefulWidget {
  final AppUser? user;
  final bool closeAfterSave;
  final Pelicula? pelicula;

  // Crea la pantalla para añadir o editar una película
  const AddPeliculaScreen({
    super.key,
    this.user,
    this.closeAfterSave = true,
    this.pelicula,
  });

  // Crea el estado del formulario de película
  @override
  State<AddPeliculaScreen> createState() => _AddPeliculaScreenState();
}

class _AddPeliculaScreenState extends State<AddPeliculaScreen> {
  final _formKey = GlobalKey<FormState>();
  static const caratulasDisponibles = [
    'assets/images/gladiator.jpg',
    'assets/images/inception.jpg',
    'assets/images/interstellar.jpg',
    'assets/images/michael.jpg',
  ];

  final tituloController = TextEditingController();
  final directorController = TextEditingController();
  final anioController = TextEditingController();
  final generoController = TextEditingController();
  final sinopsisController = TextEditingController();
  String caratulaSeleccionada = caratulasDisponibles.first;
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? imagenSeleccionadaBytes;
  String? imagenSeleccionadaNombre;
  String? imagenSeleccionadaMimeType;
  bool guardando = false;

  // Indica si el formulario está editando una película
  bool get esEdicion => widget.pelicula != null;

  // Carga los datos iniciales cuando se está editando una película
  @override
  void initState() {
    super.initState();
    final pelicula = widget.pelicula;
    if (pelicula == null) return;

    tituloController.text = pelicula.titulo;
    directorController.text = pelicula.director;
    anioController.text = pelicula.anio.toString();
    generoController.text = pelicula.genero;
    sinopsisController.text = pelicula.sinopsis;
    if (caratulasDisponibles.contains(pelicula.caratula)) {
      caratulaSeleccionada = pelicula.caratula;
    } else {
      caratulaSeleccionada = pelicula.caratula;
    }
  }

  // Permite elegir una imagen desde la galería o archivos del dispositivo
  Future<void> seleccionarCaratula() async {
    final imagen = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (imagen == null) return;

    final bytes = await imagen.readAsBytes();
    setState(() {
      imagenSeleccionadaBytes = bytes;
      imagenSeleccionadaNombre = imagen.name;
      imagenSeleccionadaMimeType = imagen.mimeType;
    });
  }

  // Sube la imagen elegida a Firebase Storage y devuelve su URL pública
  Future<String> subirCaratulaSeleccionada() async {
    final bytes = imagenSeleccionadaBytes;
    if (bytes == null) return caratulaSeleccionada;
    if (!FirebaseService.isAvailable) {
      throw Exception('Firebase no está disponible para subir la carátula');
    }

    final extension = (imagenSeleccionadaNombre?.split('.').last ?? 'jpg')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    final nombreSeguro = DateTime.now().microsecondsSinceEpoch.toString();
    final referencia = FirebaseStorage.instance
        .ref()
        .child('caratulas')
        .child('$nombreSeguro.${extension.isEmpty ? 'jpg' : extension}');

    await referencia.putData(
      bytes,
      SettableMetadata(
        contentType: imagenSeleccionadaMimeType ?? 'image/jpeg',
      ),
    );
    return referencia.getDownloadURL();
  }

  // Valida el formulario y guarda la película
  Future<void> guardarPelicula() async {
    if (_formKey.currentState!.validate() && !guardando) {
      final appState = context.read<AppState>();

      setState(() {
        guardando = true;
      });

      String caratula;
      try {
        caratula = await subirCaratulaSeleccionada();
      } catch (_) {
        if (!mounted) return;
        setState(() {
          guardando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se ha podido subir la carátula'),
          ),
        );
        return;
      }

      final pelicula = Pelicula(
        id: widget.pelicula?.id,
        titulo: tituloController.text.trim(),
        director: directorController.text.trim(),
        anio: int.parse(anioController.text.trim()),
        genero: generoController.text.trim(),
        sinopsis: sinopsisController.text.trim(),
        caratula: caratula,
        favorita: widget.pelicula?.favorita ?? false,
      );

      if (esEdicion) {
        await appState.actualizarPelicula(pelicula);
      } else {
        await appState.anadirPelicula(pelicula);
      }

      if (!mounted) return;
      if (widget.closeAfterSave || esEdicion) {
        Navigator.pop(context);
        return;
      }

      _formKey.currentState!.reset();
      tituloController.clear();
      directorController.clear();
      anioController.clear();
      generoController.clear();
      sinopsisController.clear();
      setState(() {
        caratulaSeleccionada = caratulasDisponibles.first;
        imagenSeleccionadaBytes = null;
        imagenSeleccionadaNombre = null;
        imagenSeleccionadaMimeType = null;
        guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).text('movieSaved'))),
      );
    }
  }

  // Libera los controladores de texto
  @override
  void dispose() {
    tituloController.dispose();
    directorController.dispose();
    anioController.dispose();
    generoController.dispose();
    sinopsisController.dispose();
    super.dispose();
  }

  // Crea la decoración básica de un campo
  InputDecoration deco(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }

  // Muestra el formulario para crear o editar una película
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? l10n.text('editMovie') : l10n.text('newMovie')),
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
              DropdownButtonFormField<String>(
                value: caratulasDisponibles.contains(caratulaSeleccionada)
                    ? caratulaSeleccionada
                    : null,
                decoration: deco('Carátula'),
                items: caratulasDisponibles.map((path) {
                  return DropdownMenuItem(
                    value: path,
                    child: Text(path.split('/').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    caratulaSeleccionada = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: guardando ? null : seleccionarCaratula,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  imagenSeleccionadaNombre == null
                      ? 'Elegir imagen'
                      : imagenSeleccionadaNombre!,
                ),
              ),
              if (imagenSeleccionadaBytes != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    imagenSeleccionadaBytes!,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: guardando ? null : guardarPelicula,
                child: Text(
                  guardando
                      ? 'Guardando...'
                      : esEdicion
                          ? l10n.text('saveChanges')
                          : 'Guardar película',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
