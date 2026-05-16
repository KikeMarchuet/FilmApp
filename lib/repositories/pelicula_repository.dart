import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/pelicula.dart';

class PeliculaRepository {
  // Obtiene todas las películas y marca cuáles son favoritas del usuario.
  Future<List<Pelicula>> getPeliculas(int usuarioId) async {
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
    final db = await DatabaseHelper.instance.database;
    return await db.insert('peliculas', pelicula.toMap());
  }

  // Actualiza los datos principales de una película existente.
  Future<void> updatePelicula(Pelicula pelicula) async {
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
