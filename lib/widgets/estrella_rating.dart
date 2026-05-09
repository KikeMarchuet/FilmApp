import 'package:flutter/material.dart';

class EstrellaRating extends StatelessWidget {
  final double rating;
  final double size;

  // Crea un indicador de valoración con estrellas.
  const EstrellaRating({
    super.key,
    required this.rating,
    this.size = 20,
  });

  // Muestra estrellas rellenas o vacías según la valoración.
  @override
  Widget build(BuildContext context) {
    final rounded = rating.round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rounded ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }
}
