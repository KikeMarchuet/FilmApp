import 'dart:async';

import 'package:flutter/material.dart';

class InicioScreen extends StatefulWidget {
  final VoidCallback onFinished;

  // Crea la pantalla inicial temporal de la app.
  const InicioScreen({
    super.key,
    required this.onFinished,
  });

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  Timer? timer;

  @override
  // Espera unos segundos antes de continuar.
  void initState() {
    super.initState();
    timer = Timer(const Duration(seconds: 6), widget.onFinished);
  }

  @override
  // Cancela el temporizador si la pantalla se destruye.
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Muestra la marca de la app mientras carga.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF08060D),
              Color(0xFF1B102B),
              Color(0xFF050308),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _poster('assets/images/gladiator.jpg', -132, 26, -13, 128),
                    _poster('assets/images/inception.jpg', 132, -22, 13, 128),
                    _poster('assets/images/interstellar.jpg', 0, 0, 0, 150),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              Text(
                'FilmApp',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0,
                  shadows: const [
                    Shadow(
                      color: Color(0xFF7C4DFF),
                      blurRadius: 26,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tus películas, opiniones y favoritas',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFFE8DDF8),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  color: Color(0xFFFFC107),
                  strokeWidth: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Crea una carátula inclinada para la presentación.
  Widget _poster(String path, double x, double y, double angle, double width) {
    return Transform.translate(
      offset: Offset(x, y),
      child: Transform.rotate(
        angle: angle * 0.01745,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            path,
            width: width,
            height: width * 1.48,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
