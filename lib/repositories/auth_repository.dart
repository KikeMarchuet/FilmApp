import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/app_user.dart';
import '../services/firebase_service.dart';

enum AuthResult {
  success,
  invalidCredentials,
  userAlreadyExists,
  weakPassword,
  authError,
}

class AuthResponse {
  final AuthResult result;
  final AppUser? user;

  // Guarda el resultado de autenticación y el usuario si existe
  const AuthResponse({
    required this.result,
    this.user,
  });
}

class AuthRepository {
  final firebase_auth.FirebaseAuth? _firebaseAuthOverride;
  final FirebaseFirestore? _firestoreOverride;

  // Crea el repositorio de autenticación con Firebase opcional para tests
  AuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuthOverride = firebaseAuth,
        _firestoreOverride = firestore;

  // Devuelve la instancia de Firebase Auth que se va a usar
  firebase_auth.FirebaseAuth get _firebaseAuth =>
      _firebaseAuthOverride ?? firebase_auth.FirebaseAuth.instance;

  // Devuelve la instancia de Firestore que se va a usar
  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  // Convierte la contraseña en un hash para no guardarla en claro
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Genera un id numérico estable para mantener el contrato actual de la app
  int _stableUserId(String uid) {
    var hash = 2166136261;
    for (final codeUnit in uid.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    return hash;
  }

  // Permite usar el nombre actual del formulario con Firebase Auth
  String _emailForName(String name) {
    final trimmedName = name.trim();
    if (trimmedName.contains('@')) return trimmedName.toLowerCase();

    final safeName = trimmedName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return '${safeName.isEmpty ? 'user' : safeName}@filmapp.localhost';
  }

  // Crea un usuario de la app a partir del usuario de Firebase
  AppUser _userFromFirebaseUser(
    firebase_auth.User firebaseUser,
    Map<String, dynamic>? data,
    String fallbackName,
  ) {
    final uid = firebaseUser.uid;
    return AppUser(
      id: (data?['app_id'] as num?)?.toInt() ?? _stableUserId(uid),
      name: data?['nombre'] ?? firebaseUser.displayName ?? fallbackName.trim(),
      languageCode: data?['idioma'] ?? 'ca',
      firebaseUid: uid,
    );
  }

  // Carga el usuario remoto o lo crea si todavía no existe
  Future<AppUser> _loadOrCreateRemoteUser(
    firebase_auth.User firebaseUser,
    String fallbackName,
  ) async {
    final userRef = _firestore.collection('usuarios').doc(firebaseUser.uid);
    final snapshot = await userRef.get();
    if (snapshot.exists) {
      return _userFromFirebaseUser(
        firebaseUser,
        snapshot.data(),
        fallbackName,
      );
    }

    final user = _userFromFirebaseUser(firebaseUser, null, fallbackName);
    await userRef.set({
      'app_id': user.id,
      'nombre': user.name,
      'email': firebaseUser.email,
      'idioma': user.languageCode,
      'created_at': FieldValue.serverTimestamp(),
    });
    return user;
  }

  // Comprueba si el usuario existe y si la contraseña es correcta
  Future<AuthResponse> login(String name, String password) async {
    if (FirebaseService.isAvailable) {
      try {
        final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: _emailForName(name),
          password: password,
        );
        final firebaseUser = credential.user;
        if (firebaseUser == null) {
          return const AuthResponse(result: AuthResult.invalidCredentials);
        }

        return AuthResponse(
          result: AuthResult.success,
          user: await _loadOrCreateRemoteUser(firebaseUser, name),
        );
      } on firebase_auth.FirebaseAuthException catch (error) {
        if (error.code == 'user-not-found' ||
            error.code == 'wrong-password' ||
            error.code == 'invalid-credential' ||
            error.code == 'invalid-email') {
          return const AuthResponse(result: AuthResult.invalidCredentials);
        }
        return const AuthResponse(result: AuthResult.authError);
      } catch (_) {
        return const AuthResponse(result: AuthResult.authError);
      }
    }

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

  // Crea un usuario nuevo con idioma inicial y contraseña cifrada
  Future<AuthResponse> register(String name, String password) async {
    if (FirebaseService.isAvailable) {
      try {
        final trimmedName = name.trim();
        final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: _emailForName(trimmedName),
          password: password,
        );
        final firebaseUser = credential.user;
        if (firebaseUser == null) {
          return const AuthResponse(result: AuthResult.invalidCredentials);
        }

        await firebaseUser.updateDisplayName(trimmedName);
        return AuthResponse(
          result: AuthResult.success,
          user: await _loadOrCreateRemoteUser(firebaseUser, trimmedName),
        );
      } on firebase_auth.FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          return const AuthResponse(result: AuthResult.userAlreadyExists);
        }
        if (error.code == 'weak-password') {
          return const AuthResponse(result: AuthResult.weakPassword);
        }
        if (error.code == 'invalid-email') {
          return const AuthResponse(result: AuthResult.invalidCredentials);
        }
        return const AuthResponse(result: AuthResult.authError);
      } catch (_) {
        return const AuthResponse(result: AuthResult.authError);
      }
    }

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

  // Guarda el idioma elegido por el usuario y devuelve el usuario actualizado
  Future<AppUser> updateLanguage(AppUser user, String languageCode) async {
    if (FirebaseService.isAvailable && user.firebaseUid != null) {
      await _firestore.collection('usuarios').doc(user.firebaseUid).set({
        'app_id': user.id,
        'nombre': user.name,
        'idioma': languageCode,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return user.copyWith(languageCode: languageCode);
    }

    final db = await DatabaseHelper.instance.database;
    await db.update(
      'usuarios',
      {'idioma': languageCode},
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return user.copyWith(languageCode: languageCode);
  }

  // Cierra la sesión remota si Firebase está activo
  Future<void> logout() async {
    if (FirebaseService.isAvailable) {
      await _firebaseAuth.signOut();
    }
  }
}
