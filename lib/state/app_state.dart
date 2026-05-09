import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/pelicula.dart';
import '../repositories/auth_repository.dart';
import '../repositories/opinion_repository.dart';
import '../repositories/pelicula_repository.dart';

class MovieListState {
  final List<Pelicula> peliculas;
  final Map<int, double> medias;
  final bool loading;

  // Guarda el estado visible de una lista de películas.
  const MovieListState({
    this.peliculas = const [],
    this.medias = const {},
    this.loading = false,
  });
}

class AppState extends ChangeNotifier {
  final AuthRepository authRepository;
  final PeliculaRepository peliculaRepository;
  final OpinionRepository opinionRepository;

  // Crea el estado general y permite inyectar repositorios en tests.
  AppState({
    AuthRepository? authRepository,
    PeliculaRepository? peliculaRepository,
    OpinionRepository? opinionRepository,
  })  : authRepository = authRepository ?? AuthRepository(),
        peliculaRepository = peliculaRepository ?? PeliculaRepository(),
        opinionRepository = opinionRepository ?? OpinionRepository();

  Locale _locale = const Locale('ca');
  AppUser? _user;
  MovieListState _allMovies = const MovieListState(loading: true);
  MovieListState _favoriteMovies = const MovieListState(loading: true);

  Locale get locale => _locale;
  AppUser? get user => _user;
  MovieListState get allMovies => _allMovies;
  MovieListState get favoriteMovies => _favoriteMovies;
  bool get isAuthenticated => _user != null;

  // Intenta iniciar sesión y, si es correcto, carga los datos del usuario.
  Future<AuthResponse> login(String name, String password) async {
    final response = await authRepository.login(name, password);
    if (response.result == AuthResult.success && response.user != null) {
      await _setAuthenticatedUser(response.user!);
    }
    return response;
  }

  // Crea un usuario nuevo y, si se guarda bien, lo deja con sesión iniciada.
  Future<AuthResponse> register(String name, String password) async {
    final response = await authRepository.register(name, password);
    if (response.result == AuthResult.success && response.user != null) {
      await _setAuthenticatedUser(response.user!);
    }
    return response;
  }

  // Establece el usuario activo, aplica su idioma y carga sus películas.
  Future<void> _setAuthenticatedUser(AppUser authenticatedUser) async {
    _user = authenticatedUser;
    _locale = Locale(authenticatedUser.languageCode);
    _allMovies = const MovieListState(loading: true);
    _favoriteMovies = const MovieListState(loading: true);
    notifyListeners();
    await loadMovies();
  }

  // Cierra la sesión y limpia los datos cargados en memoria.
  void logout() {
    _user = null;
    _allMovies = const MovieListState(loading: true);
    _favoriteMovies = const MovieListState(loading: true);
    notifyListeners();
  }

  // Cambia el idioma del usuario activo y lo guarda en la base de datos.
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

  // Carga películas, favoritas y valoraciones del usuario activo.
  Future<void> loadMovies() async {
    final currentUser = _user;
    if (currentUser == null) return;

    _allMovies = MovieListState(
      peliculas: _allMovies.peliculas,
      medias: _allMovies.medias,
      loading: true,
    );
    _favoriteMovies = MovieListState(
      peliculas: _favoriteMovies.peliculas,
      medias: _favoriteMovies.medias,
      loading: true,
    );
    notifyListeners();

    final all = await peliculaRepository.getPeliculas(currentUser.id);
    final favorites =
        await peliculaRepository.getPeliculasFavoritas(currentUser.id);

    _allMovies = MovieListState(
      peliculas: all,
      medias: await _loadRatings(all),
    );
    _favoriteMovies = MovieListState(
      peliculas: favorites,
      medias: await _loadRatings(favorites),
    );
    notifyListeners();
  }

  // Guarda una película nueva y actualiza las listas.
  Future<void> addMovie(Pelicula pelicula) async {
    await peliculaRepository.insertPelicula(pelicula);
    await loadMovies();
  }

  // Borra una película y actualiza las listas.
  Future<void> deleteMovie(Pelicula pelicula) async {
    final id = pelicula.id;
    if (id == null) return;

    await peliculaRepository.deletePelicula(id);
    await loadMovies();
  }

  // Marca o desmarca una película como favorita del usuario activo.
  Future<void> toggleFavorite(Pelicula pelicula) async {
    final currentUser = _user;
    if (currentUser == null || pelicula.id == null) return;

    await peliculaRepository.updateFavorita(
      currentUser.id,
      pelicula.id!,
      !pelicula.favorita,
    );
    await loadMovies();
  }

  // Calcula la valoración media de cada película recibida.
  Future<Map<int, double>> _loadRatings(List<Pelicula> peliculas) async {
    final medias = <int, double>{};
    for (final pelicula in peliculas) {
      final id = pelicula.id;
      if (id != null) {
        medias[id] = await opinionRepository.getMediaValoracion(id);
      }
    }
    return medias;
  }
}
