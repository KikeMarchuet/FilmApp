import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

class FirebaseService {
  static bool _isAvailable = false;
  static Object? _initializationError;

  // Evita crear instancias del servicio
  FirebaseService._();

  // Indica si Firebase está disponible
  static bool get isAvailable => _isAvailable;

  // Devuelve el error de inicialización si lo hubo
  static Object? get initializationError => _initializationError;

  // Inicializa Firebase si la app ya tiene configuración nativa o web
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isAvailable = true;
      _initializationError = null;
    } catch (error) {
      _isAvailable = false;
      _initializationError = error;
      if (kDebugMode) {
        debugPrint(
            'Firebase no configurado. Usando base de datos local: $error');
      }
    }
  }
}
