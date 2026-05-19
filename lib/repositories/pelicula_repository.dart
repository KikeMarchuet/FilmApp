import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/pelicula.dart';
import '../services/firebase_service.dart';

class PeliculaRepository {
  final FirebaseFirestore? _firestoreOverride;

  PeliculaRepository({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _peliculas =>
      _firestore.collection('peliculas');

  CollectionReference<Map<String, dynamic>> get _favoritas =>
      _firestore.collection('peliculas_favoritas');

  CollectionReference<Map<String, dynamic>> get _opiniones =>
      _firestore.collection('opiniones');

  Future<void> _ensureRemoteSeedData() async {
    final existing = await _peliculas.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _firestore.batch();
    final peliculas = [
      Pelicula(
        id: 1,
        titulo: 'Interstellar',
        director: 'Christopher Nolan',
        anio: 2014,
        genero: 'Ciencia ficción',
        sinopsis:
            'Un grupo de exploradores viaja por el espacio en busca de un nuevo hogar para la humanidad.',
        caratula: 'assets/images/interstellar.jpg',
      ),
      Pelicula(
        id: 2,
        titulo: 'Inception',
        director: 'Christopher Nolan',
        anio: 2010,
        genero: 'Thriller / Ciencia ficción',
        sinopsis:
            'Un ladrón especializado en robar secretos a través de los sueños recibe una misión inversa: implantar una idea.',
        caratula: 'assets/images/inception.jpg',
      ),
      Pelicula(
        id: 3,
        titulo: 'Gladiator',
        director: 'Ridley Scott',
        anio: 2000,
        genero: 'Acción / Drama histórico',
        sinopsis:
            'Un general romano traicionado busca justicia en la arena como gladiador.',
        caratula: 'assets/images/gladiator.jpg',
      ),
    ];

    for (final pelicula in peliculas) {
      batch.set(_peliculas.doc(pelicula.id.toString()), pelicula.toMap());
    }

    final opinionesIniciales = [
      {
        'id': 1,
        'pelicula_id': 1,
        'autor': 'Ana',
        'comentario': 'Una obra maestra visual y emocional.',
        'valoracion': 5,
      },
      {
        'id': 2,
        'pelicula_id': 1,
        'autor': 'Luis',
        'comentario': 'Muy interesante aunque algo compleja.',
        'valoracion': 4,
      },
      {
        'id': 3,
        'pelicula_id': 2,
        'autor': 'Marta',
        'comentario': 'Muy original y entretenida.',
        'valoracion': 5,
      },
    ];

    for (final opinion in opinionesIniciales) {
      batch.set(_opiniones.doc(opinion['id'].toString()), opinion);
    }

    await batch.commit();
  }

  Future<Set<int>> _getRemoteFavoriteIds(int usuarioId) async {
    final snapshot =
        await _favoritas.where('usuario_id', isEqualTo: usuarioId).get();
    return snapshot.docs
        .map((doc) => (doc.data()['pelicula_id'] as num).toInt())
        .toSet();
  }

  Pelicula _remoteMovieFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Set<int> favoriteIds,
  ) {
    final data = {
      ...doc.data(),
      'id': int.tryParse(doc.id) ?? doc.data()['id'],
      'favorita':
          favoriteIds.contains(int.tryParse(doc.id) ?? doc.data()['id']),
    };
    return Pelicula.fromMap(data);
  }

  // Obtiene todas las películas y marca cuáles son favoritas del usuario.
  Future<List<Pelicula>> getPeliculas(int usuarioId) async {
    if (FirebaseService.isAvailable) {
      await _ensureRemoteSeedData();
      final favoriteIds = await _getRemoteFavoriteIds(usuarioId);
      final snapshot = await _peliculas.orderBy('titulo').get();
      return snapshot.docs
          .map((doc) => _remoteMovieFromDoc(doc, favoriteIds))
          .toList();
    }

    final db = await DatabaseHelper.instance.database;
    final maps = await db.rawQuery('''
      SELECT p.*,
        CASE WHEN pf.pelicula_id IS NULL THEN 0 ELSE 1 END AS favorita
      FROM peliculas p
      LEFT JOIN peliculas_favoritas pf
        ON pf.pelicula_id = p.id AND pf.usuario_id = ?
      ORDER BY p.titulo ASC
    ''', [usuarioId]);

    return maps.map((map) => Pelicula.fromMap(map)).toList();
  }

  // Obtiene solo las películas favoritas del usuario.
  Future<List<Pelicula>> getPeliculasFavoritas(int usuarioId) async {
    if (FirebaseService.isAvailable) {
      await _ensureRemoteSeedData();
      final favoriteIds = await _getRemoteFavoriteIds(usuarioId);
      final peliculas = await getPeliculas(usuarioId);
      return peliculas
          .where((pelicula) => pelicula.id != null)
          .where((pelicula) => favoriteIds.contains(pelicula.id))
          .toList();
    }

    final db = await DatabaseHelper.instance.database;
    final maps = await db.rawQuery('''
      SELECT p.*, 1 AS favorita
      FROM peliculas p
      INNER JOIN peliculas_favoritas pf ON pf.pelicula_id = p.id
      WHERE pf.usuario_id = ?
      ORDER BY p.titulo ASC
    ''', [usuarioId]);

    return maps.map((map) => Pelicula.fromMap(map)).toList();
  }

  // Guarda una película nueva y devuelve su id.
  Future<int> insertPelicula(Pelicula pelicula) async {
    if (FirebaseService.isAvailable) {
      final id = DateTime.now().microsecondsSinceEpoch;
      await _peliculas.doc(id.toString()).set({
        ...pelicula.toMap(),
        'id': id,
      });
      return id;
    }

    final db = await DatabaseHelper.instance.database;
    return await db.insert('peliculas', pelicula.toMap());
  }

  // Actualiza los datos principales de una película existente.
  Future<void> updatePelicula(Pelicula pelicula) async {
    if (FirebaseService.isAvailable) {
      final id = pelicula.id;
      if (id == null) return;
      await _peliculas.doc(id.toString()).set(pelicula.toMap());
      return;
    }

    final db = await DatabaseHelper.instance.database;
    await db.update(
      'peliculas',
      pelicula.toMap(),
      where: 'id = ?',
      whereArgs: [pelicula.id],
    );
  }

  // Elimina una película y sus datos relacionados.
  Future<void> deletePelicula(int id) async {
    if (FirebaseService.isAvailable) {
      final batch = _firestore.batch();
      final favoritasSnapshot =
          await _favoritas.where('pelicula_id', isEqualTo: id).get();
      final opinionesSnapshot =
          await _opiniones.where('pelicula_id', isEqualTo: id).get();

      for (final doc in favoritasSnapshot.docs) {
        batch.delete(doc.reference);
      }
      for (final doc in opinionesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_peliculas.doc(id.toString()));
      await batch.commit();
      return;
    }

    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.delete(
        'peliculas_favoritas',
        where: 'pelicula_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'opiniones',
        where: 'pelicula_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'peliculas',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // Marca o desmarca una película como favorita del usuario.
  Future<void> updateFavorita(
      int usuarioId, int peliculaId, bool favorita) async {
    if (FirebaseService.isAvailable) {
      final favoriteRef = _favoritas.doc('${usuarioId}_$peliculaId');
      if (favorita) {
        await favoriteRef.set({
          'usuario_id': usuarioId,
          'pelicula_id': peliculaId,
          'created_at': FieldValue.serverTimestamp(),
        });
        return;
      }

      await favoriteRef.delete();
      return;
    }

    final db = await DatabaseHelper.instance.database;
    if (favorita) {
      await db.insert(
        'peliculas_favoritas',
        {
          'usuario_id': usuarioId,
          'pelicula_id': peliculaId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return;
    }

    await db.delete(
      'peliculas_favoritas',
      where: 'usuario_id = ? AND pelicula_id = ?',
      whereArgs: [usuarioId, peliculaId],
    );
  }

  // Busca una película por su id.
  Future<Pelicula?> getPeliculaById(int id) async {
    if (FirebaseService.isAvailable) {
      final snapshot = await _peliculas.doc(id.toString()).get();
      if (!snapshot.exists || snapshot.data() == null) return null;
      return Pelicula.fromMap({
        ...snapshot.data()!,
        'id': id,
      });
    }

    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'peliculas',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Pelicula.fromMap(maps.first);
    }
    return null;
  }
}
