class Pelicula {
  final int? id;
  final String titulo;
  final String director;
  final int anio;
  final String genero;
  final String sinopsis;
  final String caratula;
  final bool favorita;

  // Crea una película con sus datos principales
  Pelicula({
    this.id,
    required this.titulo,
    required this.director,
    required this.anio,
    required this.genero,
    required this.sinopsis,
    required this.caratula,
    this.favorita = false,
  });

  // Convierte el objeto Pelicula en un mapa clave-valor para poder almacenarlo en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'director': director,
      'anio': anio,
      'genero': genero,
      'sinopsis': sinopsis,
      'caratula': caratula,
      'favorita': favorita ? 1 : 0,
    };
  }

  // Crea una instancia de Pelicula a partir de un mapa obtenido de la base de datos
  factory Pelicula.fromMap(Map<String, dynamic> map) {
    final favorita = map['favorita'];
    return Pelicula(
      id: (map['id'] as num?)?.toInt(),
      titulo: map['titulo'],
      director: map['director'],
      anio: (map['anio'] as num).toInt(),
      genero: map['genero'],
      sinopsis: map['sinopsis'],
      caratula: map['caratula'],
      favorita: favorita == true || favorita == 1,
    );
  }
}
