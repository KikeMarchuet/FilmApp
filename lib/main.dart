import 'package:flutter/material.dart';
import 'app.dart';
import 'services/firebase_service.dart';

// Arranca la aplicación
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const FilmApp());
}
