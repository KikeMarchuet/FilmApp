import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Evita crear instancias desde fuera de esta clase.
  DatabaseHelper._init();

  // Devuelve la base de datos abierta o la crea si aún no existe.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('filmapp.db');
    return _database!;
  }

  // Prepara la ruta del archivo y abre la base de datos.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // Crea todas las tablas cuando la base de datos es nueva.
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE peliculas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        director TEXT NOT NULL,
        anio INTEGER NOT NULL,
        genero TEXT NOT NULL,
        sinopsis TEXT NOT NULL,
        caratula TEXT NOT NULL,
        favorita INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        idioma TEXT NOT NULL DEFAULT 'ca'
      )
    ''');

    await db.execute('''
      CREATE TABLE peliculas_favoritas (
        usuario_id INTEGER NOT NULL,
        pelicula_id INTEGER NOT NULL,
        PRIMARY KEY (usuario_id, pelicula_id),
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
        FOREIGN KEY (pelicula_id) REFERENCES peliculas (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE opiniones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pelicula_id INTEGER NOT NULL,
        autor TEXT NOT NULL,
        comentario TEXT NOT NULL,
        valoracion INTEGER NOT NULL,
        FOREIGN KEY (pelicula_id) REFERENCES peliculas (id) ON DELETE CASCADE
      )
    ''');

    await _insertarDatosIniciales(db);
  }

  // Aplica cambios de estructura a bases de datos ya existentes.
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE peliculas ADD COLUMN favorita INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 3) {
      await _createUserTables(db);
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE usuarios ADD COLUMN idioma TEXT NOT NULL DEFAULT 'ca'",
      );
    }
  }

  // Crea las tablas de usuarios y favoritas si no existen.
  Future<void> _createUserTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        idioma TEXT NOT NULL DEFAULT 'ca'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS peliculas_favoritas (
        usuario_id INTEGER NOT NULL,
        pelicula_id INTEGER NOT NULL,
        PRIMARY KEY (usuario_id, pelicula_id),
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
        FOREIGN KEY (pelicula_id) REFERENCES peliculas (id) ON DELETE CASCADE
      )
    ''');
  }

  // Inserta películas y opiniones de ejemplo al crear la base de datos.
  Future<void> _insertarDatosIniciales(Database db) async {
    await db.insert('peliculas', {
      'titulo': 'Interstellar',
      'director': 'Christopher Nolan',
      'anio': 2014,
      'genero': 'Ciencia ficción',
      'sinopsis':
          'Un grupo de exploradores viaja por el espacio en busca de un nuevo hogar para la humanidad.',
      'caratula': 'assets/images/interstellar.jpg',
      'favorita': 1,
    });

    await db.insert('peliculas', {
      'titulo': 'Inception',
      'director': 'Christopher Nolan',
      'anio': 2010,
      'genero': 'Thriller / Ciencia ficción',
      'sinopsis':
          'Un ladrón especializado en robar secretos a través de los sueños recibe una misión inversa: implantar una idea.',
      'caratula': 'assets/images/inception.jpg',
    });

    await db.insert('peliculas', {
      'titulo': 'Gladiator',
      'director': 'Ridley Scott',
      'anio': 2000,
      'genero': 'Acción / Drama histórico',
      'sinopsis':
          'Un general romano traicionado busca justicia en la arena como gladiador.',
      'caratula': 'assets/images/gladiator.jpg',
    });

    await db.insert('opiniones', {
      'pelicula_id': 1,
      'autor': 'Ana',
      'comentario': 'Una obra maestra visual y emocional.',
      'valoracion': 5,
    });

    await db.insert('opiniones', {
      'pelicula_id': 1,
      'autor': 'Luis',
      'comentario': 'Muy interesante aunque algo compleja.',
      'valoracion': 4,
    });

    await db.insert('opiniones', {
      'pelicula_id': 2,
      'autor': 'Marta',
      'comentario': 'Muy original y entretenida.',
      'valoracion': 5,
    });
  }
}
