# FilmApp

Aplicación Flutter de gestión de películas con autenticación, favoritas,
opiniones y persistencia.

## Firebase

El código está preparado para usar Firebase Authentication y Cloud Firestore
cuando Firebase esté configurado. Si no existe configuración Firebase, la app
sigue funcionando con la base de datos local SQLite para desarrollo y tests.

Pasos para activar Firebase:

1. Crear un proyecto en Firebase Console.
2. Activar Authentication con proveedor email/contraseña.
3. Crear una base de datos Cloud Firestore.
4. Instalar FlutterFire CLI si no está instalado:

```bash
dart pub global activate flutterfire_cli
```

5. Configurar la app desde la raíz del proyecto:

```bash
flutterfire configure
```

El identificador Android actual es `com.kike.film_app`.

Las reglas iniciales están en `firestore.rules`. Se pueden publicar con:

```bash
firebase deploy --only firestore:rules
```

Con Firebase activo, la app guarda estos datos en Firestore:

- `usuarios`: perfil, idioma y relación con Firebase Auth.
- `peliculas`: catálogo de películas.
- `peliculas_favoritas`: favoritas por usuario.
- `opiniones`: comentarios y valoraciones.

## Desarrollo

```bash
flutter pub get
flutter analyze
flutter test
```
