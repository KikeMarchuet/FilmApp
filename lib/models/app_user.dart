class AppUser {
  final int id;
  final String name;
  final String languageCode;
  final String? firebaseUid;

  // Crea un usuario con su idioma guardado.
  const AppUser({
    required this.id,
    required this.name,
    required this.languageCode,
    this.firebaseUid,
  });

  // Crea un usuario a partir de una fila de la base de datos.
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      name: map['nombre'],
      languageCode: map['idioma'] ?? 'ca',
      firebaseUid: map['firebase_uid'],
    );
  }

  // Devuelve una copia cambiando solo los datos indicados.
  AppUser copyWith({
    String? languageCode,
    String? firebaseUid,
  }) {
    return AppUser(
      id: id,
      name: name,
      languageCode: languageCode ?? this.languageCode,
      firebaseUid: firebaseUid ?? this.firebaseUid,
    );
  }
}
