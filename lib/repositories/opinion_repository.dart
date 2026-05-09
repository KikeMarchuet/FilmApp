import '../database/database_helper.dart';
import '../models/opinion.dart';

class OpinionRepository {
  // Obtiene las opiniones de una película.
  Future<List<Opinion>> getOpinionesByPelicula(int peliculaId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'opiniones',
      where: 'pelicula_id = ?',
      whereArgs: [peliculaId],
      orderBy: 'id DESC',
    );
    return maps.map((map) => Opinion.fromMap(map)).toList();
  }

  // Guarda una opinión nueva y devuelve su id.
  Future<int> insertOpinion(Opinion opinion) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('opiniones', opinion.toMap());
  }

  // Calcula la valoración media de una película.
  Future<double> getMediaValoracion(int peliculaId) async {
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
