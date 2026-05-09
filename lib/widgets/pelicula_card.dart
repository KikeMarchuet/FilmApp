import 'package:flutter/material.dart';
import '../models/pelicula.dart';
import 'estrella_rating.dart';

class PeliculaCard extends StatelessWidget {
  final Pelicula pelicula;
  final double media;
  final VoidCallback onTap;

  // Crea una tarjeta de película para el listado.
  const PeliculaCard({
    super.key,
    required this.pelicula,
    required this.media,
    required this.onTap,
  });

  // Muestra la información básica de una película.
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.asset(
                pelicula.caratula,
                width: 100,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pelicula.titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text('${pelicula.genero} · ${pelicula.anio}'),
                        ),
                        if (pelicula.favorita)
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    EstrellaRating(rating: media),
                    const SizedBox(height: 4),
                    Text('Media: ${media.toStringAsFixed(1)} / 5'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
