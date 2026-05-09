import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;

  // Guarda el idioma que se usará para buscar textos.
  AppLocalizations(this.locale);

  static const supportedLocales = [
    Locale('ca'),
    Locale('es'),
    Locale('en'),
  ];

  // Obtiene las traducciones desde el contexto actual.
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _values = {
    'ca': {
      'appTitle': 'FilmApp',
      'loginTitle': 'Inicia sessió',
      'loginSubtitle': 'Accedeix al teu espai de pel·lícules',
      'userName': 'Nom d\'usuari',
      'password': 'Contrasenya',
      'login': 'Entrar',
      'createAccount': 'Crear usuari',
      'alreadyHaveAccount': 'Ja tinc usuari',
      'confirmPassword': 'Repeteix la contrasenya',
      'loginError': 'Introdueix usuari i contrasenya',
      'invalidCredentials': 'Usuari o contrasenya incorrectes',
      'passwordMismatch': 'Les contrasenyes no coincideixen',
      'userAlreadyExists': 'Aquest usuari ja existeix',
      'moviesList': 'Llistat de pel·lícules',
      'favoriteMovies': 'Pel·lícules preferides',
      'addMovie': 'Afegir pel·lícula',
      'movies': 'Pel·lícules',
      'favorites': 'Preferides',
      'add': 'Afegir',
      'settings': 'Configuració',
      'settingsTitle': 'Configuració',
      'account': 'Compte',
      'language': 'Idioma',
      'logout': 'Tancar sessió',
      'loggedInAs': 'Sessió iniciada com a {user}',
      'noMovies': 'Encara no hi ha pel·lícules registrades.',
      'noFavorites': 'Encara no hi ha pel·lícules preferides.',
      'newMovie': 'Nova pel·lícula',
      'movieSaved': 'Pel·lícula guardada',
      'markFavorite': 'Marcar com a preferida',
      'removeFavorite': 'Llevar de preferides',
      'deleteMovie': 'Esborrar pel·lícula',
      'deleteMovieTitle': 'Esborrar pel·lícula',
      'deleteMovieMessage': 'Vols esborrar aquesta pel·lícula?',
      'cancel': 'Cancel·lar',
      'delete': 'Esborrar',
    },
    'es': {
      'appTitle': 'FilmApp',
      'loginTitle': 'Iniciar sesión',
      'loginSubtitle': 'Accede a tu espacio de películas',
      'userName': 'Nombre de usuario',
      'password': 'Contraseña',
      'login': 'Entrar',
      'createAccount': 'Crear usuario',
      'alreadyHaveAccount': 'Ya tengo usuario',
      'confirmPassword': 'Repite la contraseña',
      'loginError': 'Introduce usuario y contraseña',
      'invalidCredentials': 'Usuario o contraseña incorrectos',
      'passwordMismatch': 'Las contraseñas no coinciden',
      'userAlreadyExists': 'Este usuario ya existe',
      'moviesList': 'Listado de películas',
      'favoriteMovies': 'Películas preferidas',
      'addMovie': 'Añadir película',
      'movies': 'Películas',
      'favorites': 'Preferidas',
      'add': 'Añadir',
      'settings': 'Configuración',
      'settingsTitle': 'Configuración',
      'account': 'Cuenta',
      'language': 'Idioma',
      'logout': 'Cerrar sesión',
      'loggedInAs': 'Sesión iniciada como {user}',
      'noMovies': 'No hay películas registradas todavía.',
      'noFavorites': 'No hay películas preferidas todavía.',
      'newMovie': 'Nueva película',
      'movieSaved': 'Película guardada',
      'markFavorite': 'Marcar como preferida',
      'removeFavorite': 'Quitar de preferidas',
      'deleteMovie': 'Borrar película',
      'deleteMovieTitle': 'Borrar película',
      'deleteMovieMessage': '¿Quieres borrar esta película?',
      'cancel': 'Cancelar',
      'delete': 'Borrar',
    },
    'en': {
      'appTitle': 'FilmApp',
      'loginTitle': 'Sign in',
      'loginSubtitle': 'Access your movie space',
      'userName': 'Username',
      'password': 'Password',
      'login': 'Sign in',
      'createAccount': 'Create user',
      'alreadyHaveAccount': 'I already have a user',
      'confirmPassword': 'Repeat password',
      'loginError': 'Enter username and password',
      'invalidCredentials': 'Incorrect username or password',
      'passwordMismatch': 'Passwords do not match',
      'userAlreadyExists': 'This user already exists',
      'moviesList': 'Movie list',
      'favoriteMovies': 'Favorite movies',
      'addMovie': 'Add movie',
      'movies': 'Movies',
      'favorites': 'Favorites',
      'add': 'Add',
      'settings': 'Settings',
      'settingsTitle': 'Settings',
      'account': 'Account',
      'language': 'Language',
      'logout': 'Sign out',
      'loggedInAs': 'Signed in as {user}',
      'noMovies': 'There are no movies yet.',
      'noFavorites': 'There are no favorite movies yet.',
      'newMovie': 'New movie',
      'movieSaved': 'Movie saved',
      'markFavorite': 'Mark as favorite',
      'removeFavorite': 'Remove from favorites',
      'deleteMovie': 'Delete movie',
      'deleteMovieTitle': 'Delete movie',
      'deleteMovieMessage': 'Do you want to delete this movie?',
      'cancel': 'Cancel',
      'delete': 'Delete',
    },
  };

  // Devuelve el texto traducido para una clave.
  String text(String key) {
    return _values[locale.languageCode]?[key] ?? _values['ca']![key] ?? key;
  }

  // Devuelve el texto de sesión iniciada con el nombre del usuario.
  String loggedInAs(String user) {
    return Intl.message(
      text('loggedInAs').replaceFirst('{user}', user),
      name: 'loggedInAs',
      args: [user],
    );
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  // Crea el delegado que Flutter usa para cargar traducciones.
  const _AppLocalizationsDelegate();

  @override
  // Indica si el idioma solicitado está soportado.
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((supportedLocale) => supportedLocale.languageCode)
        .contains(locale.languageCode);
  }

  @override
  // Carga las traducciones para el idioma activo.
  Future<AppLocalizations> load(Locale locale) async {
    Intl.defaultLocale = locale.languageCode;
    return AppLocalizations(locale);
  }

  @override
  // Evita recargar el delegado si no ha cambiado.
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
