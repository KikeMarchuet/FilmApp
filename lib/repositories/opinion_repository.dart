import 'package:cloud_firestore/cloud_firestore.dart';

import '../database/database_helper.dart';
import '../models/opinion.dart';
import '../services/firebase_service.dart';

class OpinionRepository {
  final FirebaseFirestore? _firestoreOverride;

  // Crea el repositorio de opiniones con Firestore opcional para tests
  OpinionRepository({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  // Devuelve la instancia de Firestore que se va a usar
  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  // Devuelve la colección remota de opiniones
  CollectionReference<Map<String, dynamic>> get _opiniones =>
      _firestore.collection('opiniones');

  // Obtiene las opiniones de una película
  Future<List<Opinion>> obtenerOpinionesPorPelicula(int peliculaId) async {
    if (FirebaseService.isAvailable) {
      final snapshot = await _opiniones
          .where('pelicula_id', isEqualTo: peliculaId)
          .orderBy('id', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return Opinion.fromMap({
          ...doc.data(),
          'id': int.tryParse(doc.id) ?? doc.data()['id'],
        });
      }).toList();
    }

    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'opiniones',
      where: 'pelicula_id = ?',
      whereArgs: [peliculaId],
      orderBy: 'id DESC',
    );
    return maps.map((map) => Opinion.fromMap(map)).toList();
  }

  // Guarda una opinión nueva y devuelve su id
  Future<int> insertarOpinion(Opinion opinion) async {
    if (FirebaseService.isAvailable) {
      final id = DateTime.now().microsecondsSinceEpoch;
      await _opiniones.doc(id.toString()).set({
        ...opinion.toMap(),
        'id': id,
        'created_at': FieldValue.serverTimestamp(),
      });
      return id;
    }

    final db = await DatabaseHelper.instance.database;
    return await db.insert('opiniones', opinion.toMap());
  }

  // Calcula la valoración media de una película
  Future<double> obtenerMediaValoracion(int peliculaId) async {
    if (FirebaseService.isAvailable) {
      final snapshot =
          await _opiniones.where('pelicula_id', isEqualTo: peliculaId).get();
      if (snapshot.docs.isEmpty) return 0.0;

      final total = snapshot.docs.fold<int>(
        0,
        (total, doc) => total + (doc.data()['valoracion'] as num).toInt(),
      );
      return total / snapshot.docs.length;
    }

    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT AVG(valoracion) as media
      FROM opiniones
      WHERE pelicula_id = ?
    ''', [peliculaId]);

    final media = result.first['media'];
    if (media == null) return 0.0;
    return (media as num).toDouble();
  }
}
