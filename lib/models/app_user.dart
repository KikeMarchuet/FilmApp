class AppUser {
  final int id;
  final String name;
  final String languageCode;

  // Crea un usuario con su idioma guardado.
  const AppUser({
    required this.id,
    required this.name,
    required this.languageCode,
  });

  // Crea un usuario a partir de una fila de la base de datos.
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      name: map['nombre'],
      languageCode: map['idioma'] ?? 'ca',
    );
  }

  // Devuelve una copia cambiando solo los datos indicados.
  AppUser copyWith({
    String? languageCode,
  }) {
    return AppUser(
      id: id,
      name: name,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
