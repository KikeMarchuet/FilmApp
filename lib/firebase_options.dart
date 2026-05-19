import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw StateError(
      'Firebase no está configurado. Ejecuta `flutterfire configure`.',
    );
  }
}
