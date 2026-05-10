import 'package:flutter/material.dart';

class CaratulaImage extends StatelessWidget {
  final String path;
  final double width;
  final double height;
  final BoxFit fit;

  // Crea una imagen de carátula con fallback si no existe.
  const CaratulaImage({
    super.key,
    required this.path,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  // Muestra la imagen o un bloque neutro si falla la carga.
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Icon(
            Icons.movie_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 36,
          ),
        );
      },
    );
  }
}
