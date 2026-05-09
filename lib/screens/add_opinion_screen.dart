import 'package:flutter/material.dart';
import '../models/opinion.dart';
import '../repositories/opinion_repository.dart';

class AddOpinionScreen extends StatefulWidget {
  final int peliculaId;

  // Crea la pantalla para añadir una opinión.
  const AddOpinionScreen({super.key, required this.peliculaId});

  @override
  State<AddOpinionScreen> createState() => _AddOpinionScreenState();
}

class _AddOpinionScreenState extends State<AddOpinionScreen> {
  final _formKey = GlobalKey<FormState>();
  final OpinionRepository repository = OpinionRepository();

  final autorController = TextEditingController();
  final comentarioController = TextEditingController();
  int valoracion = 3;

  // Valida el formulario y guarda la opinión.
  Future<void> guardarOpinion() async {
    if (_formKey.currentState!.validate()) {
      final opinion = Opinion(
        peliculaId: widget.peliculaId,
        autor: autorController.text.trim(),
        comentario: comentarioController.text.trim(),
        valoracion: valoracion,
      );

      await repository.insertOpinion(opinion);

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  // Libera los controladores de texto.
  @override
  void dispose() {
    autorController.dispose();
    comentarioController.dispose();
    super.dispose();
  }

  // Crea la decoración básica de un campo.
  InputDecoration deco(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }

  // Muestra las estrellas para elegir valoración.
  Widget buildStarsSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return IconButton(
          onPressed: () {
            setState(() {
              valoracion = starValue;
            });
          },
          icon: Icon(
            starValue <= valoracion ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
        );
      }),
    );
  }

  // Muestra el formulario para crear una opinión.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva opinión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: autorController,
                decoration: deco('Autor'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Introduce el autor'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: comentarioController,
                maxLines: 4,
                decoration: deco('Comentario'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Introduce el comentario'
                    : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Valoración',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildStarsSelector(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: guardarOpinion,
                child: const Text('Guardar opinión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
