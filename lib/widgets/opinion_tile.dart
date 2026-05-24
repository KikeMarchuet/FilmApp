import 'package:flutter/material.dart';
import '../models/opinion.dart';
import 'estrella_rating.dart';

class OpinionTile extends StatelessWidget {
  final Opinion opinion;

  // Crea una tarjeta para mostrar una opinión
  const OpinionTile({super.key, required this.opinion});

  // Muestra autor, valoración y comentario
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              opinion.autor,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            EstrellaRating(rating: opinion.valoracion.toDouble()),
            const SizedBox(height: 8),
            Text(opinion.comentario),
          ],
        ),
      ),
    );
  }
}
