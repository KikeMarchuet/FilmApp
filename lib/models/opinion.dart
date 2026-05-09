class Opinion {
  final int? id;
  final int peliculaId;
  final String autor;
  final String comentario;
  final int valoracion;

  // Crea una opinión asociada a una película.
  Opinion({
    this.id,
    required this.peliculaId,
    required this.autor,
    required this.comentario,
    required this.valoracion,
  });

  // Convierte el objeto Opinion en un mapa clave-valor para poder almacenarlo en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pelicula_id': peliculaId,
      'autor': autor,
      'comentario': comentario,
      'valoracion': valoracion,
    };
  }

  // Crea una instancia de Opinion a partir de un mapa obtenido de la base de datos
  factory Opinion.fromMap(Map<String, dynamic> map) {
    return Opinion(
      id: map['id'],
      peliculaId: map['pelicula_id'],
      autor: map['autor'],
      comentario: map['comentario'],
      valoracion: map['valoracion'],
    );
  }
}
