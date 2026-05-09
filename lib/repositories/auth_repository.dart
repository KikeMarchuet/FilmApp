import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/app_user.dart';

enum AuthResult {
  success,
  invalidCredentials,
  userAlreadyExists,
}

class AuthResponse {
  final AuthResult result;
  final AppUser? user;

  // Guarda el resultado de autenticación y el usuario si existe.
  const AuthResponse({
    required this.result,
    this.user,
  });
}

class AuthRepository {
  // Convierte la contraseña en un hash para no guardarla en claro.
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Comprueba si el usuario existe y si la contraseña es correcta.
  Future<AuthResponse> login(String name, String password) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'usuarios',
      where: 'LOWER(nombre) = LOWER(?)',
      whereArgs: [name.trim()],
      limit: 1,
    );

    if (maps.isEmpty) {
      return const AuthResponse(result: AuthResult.invalidCredentials);
    }

    final passwordHash = _hashPassword(password);
    if (maps.first['password_hash'] != passwordHash) {
      return const AuthResponse(result: AuthResult.invalidCredentials);
    }

    return AuthResponse(
      result: AuthResult.success,
      user: AppUser.fromMap(maps.first),
    );
  }

  // Crea un usuario nuevo con idioma inicial y contraseña cifrada.
  Future<AuthResponse> register(String name, String password) async {
    final db = await DatabaseHelper.instance.database;
    final trimmedName = name.trim();

    try {
      final id = await db.insert(
        'usuarios',
        {
          'nombre': trimmedName,
          'password_hash': _hashPassword(password),
          'idioma': 'ca',
        },
      );

      return AuthResponse(
        result: AuthResult.success,
        user: AppUser(id: id, name: trimmedName, languageCode: 'ca'),
      );
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        return const AuthResponse(result: AuthResult.userAlreadyExists);
      }
      rethrow;
    }
  }

  // Guarda el idioma elegido por el usuario y devuelve el usuario actualizado.
  Future<AppUser> updateLanguage(AppUser user, String languageCode) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'usuarios',
      {'idioma': languageCode},
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return user.copyWith(languageCode: languageCode);
  }
}
