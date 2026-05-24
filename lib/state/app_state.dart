import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/pelicula.dart';
import '../repositories/auth_repository.dart';
import '../repositories/opinion_repository.dart';
import '../repositories/pelicula_repository.dart';

class EstadoListaPeliculas {
  final List<Pelicula> peliculas;
  final Map<int, double> medias;
  final bool cargando;

  // Guarda el estado visible de una lista de películas
  const EstadoListaPeliculas({
    this.peliculas = const [],
    this.medias = const {},
    this.cargando = false,
  });
}

class AppState extends ChangeNotifier {
  final AuthRepository authRepository;
  final PeliculaRepository peliculaRepository;
  final OpinionRepository opinionRepository;

  // Crea el estado general y permite inyectar repositorios en tests
  AppState({
    AuthRepository? authRepository,
    PeliculaRepository? peliculaRepository,
    OpinionRepository? opinionRepository,
  })  : authRepository = authRepository ?? AuthRepository(),
        peliculaRepository = peliculaRepository ?? PeliculaRepository(),
        opinionRepository = opinionRepository ?? OpinionRepository();

  Locale _locale = const Locale('ca');
  AppUser? _user;
  EstadoListaPeliculas _todasLasPeliculas =
      const EstadoListaPeliculas(cargando: true);
  EstadoListaPeliculas _peliculasFavoritas =
      const EstadoListaPeliculas(cargando: true);

  // Devuelve el idioma activo
  Locale get locale => _locale;

  // Devuelve el usuario activo
  AppUser? get user => _user;

  // Devuelve el estado de todas las películas
  EstadoListaPeliculas get todasLasPeliculas => _todasLasPeliculas;

  // Devuelve el estado de las películas favoritas
  EstadoListaPeliculas get peliculasFavoritas => _peliculasFavoritas;

  // Indica si hay un usuario autenticado
  bool get isAuthenticated => _user != null;

  // Intenta iniciar sesión y, si es correcto, carga los datos del usuario
  Future<AuthResponse> login(String name, String password) async {
    final response = await authRepository.login(name, password);
    if (response.result == AuthResult.success && response.user != null) {
      await _setAuthenticatedUser(response.user!);
    }
    return response;
  }

  // Crea un usuario nuevo y, si se guarda bien, lo deja con sesión iniciada
  Future<AuthResponse> register(String name, String password) async {
    final response = await authRepository.register(name, password);
    if (response.result == AuthResult.success && response.user != null) {
      await _setAuthenticatedUser(response.user!);
    }
    return response;
  }

  // Establece el usuario activo, aplica su idioma y carga sus películas
  Future<void> _setAuthenticatedUser(AppUser authenticatedUser) async {
    _user = authenticatedUser;
    _locale = Locale(authenticatedUser.languageCode);
    _todasLasPeliculas = const EstadoListaPeliculas(cargando: true);
    _peliculasFavoritas = const EstadoListaPeliculas(cargando: true);
    notifyListeners();
    await cargarPeliculas();
  }

  // Cierra la sesión y limpia los datos cargados en memoria
  Future<void> logout() async {
    await authRepository.logout();
    _user = null;
    _todasLasPeliculas = const EstadoListaPeliculas(cargando: true);
    _peliculasFavoritas = const EstadoListaPeliculas(cargando: true);
    notifyListeners();
  }

  // Cambia el idioma del usuario activo y lo guarda en la base de datos
  Future<void> changeLocale(Locale newLocale) async {
    final currentUser = _user;
    if (currentUser == null) return;

    final updatedUser = await authRepository.updateLanguage(
      currentUser,
      newLocale.languageCode,
    );
    _user = updatedUser;
    _locale = newLocale;
    notifyListeners();
  }

  // Carga películas, favoritas y valoraciones del usuario activo
  Future<void> cargarPeliculas() async {
    final currentUser = _user;
    if (currentUser == null) return;

    _todasLasPeliculas = EstadoListaPeliculas(
      peliculas: _todasLasPeliculas.peliculas,
      medias: _todasLasPeliculas.medias,
      cargando: true,
    );
    _peliculasFavoritas = EstadoListaPeliculas(
      peliculas: _peliculasFavoritas.peliculas,
      medias: _peliculasFavoritas.medias,
      cargando: true,
    );
    notifyListeners();

    final todas = await peliculaRepository.obtenerPeliculas(currentUser.id);
    final favoritas =
        await peliculaRepository.obtenerPeliculasFavoritas(currentUser.id);

    _todasLasPeliculas = EstadoListaPeliculas(
      peliculas: todas,
      medias: await _cargarValoraciones(todas),
    );
    _peliculasFavoritas = EstadoListaPeliculas(
      peliculas: favoritas,
      medias: await _cargarValoraciones(favoritas),
    );
    notifyListeners();
  }

  // Guarda una película nueva y actualiza las listas
  Future<void> anadirPelicula(Pelicula pelicula) async {
    await peliculaRepository.insertarPelicula(pelicula);
    await cargarPeliculas();
  }

  // Actualiza una película existente y refresca las listas
  Future<void> actualizarPelicula(Pelicula pelicula) async {
    if (pelicula.id == null) return;

    await peliculaRepository.actualizarPelicula(pelicula);
    await cargarPeliculas();
  }

  // Borra una película y actualiza las listas
  Future<void> eliminarPelicula(Pelicula pelicula) async {
    final id = pelicula.id;
    if (id == null) return;

    await peliculaRepository.eliminarPelicula(id);
    await cargarPeliculas();
  }

  // Marca o desmarca una película como favorita del usuario activo
  Future<void> cambiarFavorita(Pelicula pelicula) async {
    final currentUser = _user;
    if (currentUser == null || pelicula.id == null) return;

    await peliculaRepository.actualizarFavorita(
      currentUser.id,
      pelicula.id!,
      !pelicula.favorita,
    );
    await cargarPeliculas();
  }

  // Calcula la valoración media de cada película recibida
  Future<Map<int, double>> _cargarValoraciones(List<Pelicula> peliculas) async {
    final medias = <int, double>{};
    for (final pelicula in peliculas) {
      final id = pelicula.id;
      if (id != null) {
        medias[id] = await opinionRepository.obtenerMediaValoracion(id);
      }
    }
    return medias;
  }
}
