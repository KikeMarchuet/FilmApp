import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:film_app/app.dart';

// Comprueba el flujo principal de la app en un test de widgets.
void main() {
  late Directory databaseDirectory;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;

    databaseDirectory = await Directory.systemTemp.createTemp('film_app_test_');
    await databaseFactory.setDatabasesPath(databaseDirectory.path);
  });

  tearDownAll(() async {
    if (await databaseDirectory.exists()) {
      await databaseDirectory.delete(recursive: true);
    }
  });

  testWidgets('FilmApp starts with bottom navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FilmApp());
    await tester.pump();

    expect(find.text('FilmApp'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pump();

    expect(find.text('Inicia sessió'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Crear usuari'));
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'Tester');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.enterText(find.byType(TextFormField).at(2), 'secret');
    await tester.tap(find.text('Crear usuari').last);
    await tester.pump();

    for (var i = 0;
        i < 20 && find.text('Interstellar').evaluate().isEmpty;
        i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Llistat de pel·lícules'), findsOneWidget);
    expect(find.text('Interstellar'), findsOneWidget);
    expect(find.text('Pel·lícules'), findsOneWidget);
    expect(find.text('Preferides'), findsOneWidget);
    expect(find.text('Afegir'), findsOneWidget);
    expect(find.text('Configuració'), findsOneWidget);
    expect(find.text('Tester'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'inter');
    await tester.pump();

    expect(find.text('Interstellar'), findsOneWidget);
    expect(find.text('Inception'), findsNothing);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    await tester.tap(find.text('Interstellar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Marcar com a preferida'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preferides'));
    await tester.pump();

    for (var i = 0;
        i < 20 && find.text('Interstellar').evaluate().isEmpty;
        i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Pel·lícules preferides'), findsOneWidget);
    expect(find.text('Interstellar'), findsOneWidget);

    await tester.tap(find.text('Pel·lícules'));
    await tester.pump();
    await tester.tap(find.text('Inception'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Esborrar pel·lícula'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Esborrar'));
    await tester.pumpAndSettle();

    expect(find.text('Inception'), findsNothing);

    await tester.tap(find.text('Afegir'));
    await tester.pump();

    expect(find.text('Nova pel·lícula'), findsOneWidget);

    await tester.tap(find.text('Configuració'));
    await tester.pump();

    expect(find.text('Sessió iniciada com a Tester'), findsOneWidget);

    await tester.tap(find.text('Valencià / Català'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Castellano').last);
    await tester.pumpAndSettle();

    expect(find.text('Configuración'), findsWidgets);

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Crear usuario'));
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'Other');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.enterText(find.byType(TextFormField).at(2), 'secret');
    await tester.tap(find.text('Crear usuario').last);
    await tester.pump();

    for (var i = 0;
        i < 20 && find.text('Interstellar').evaluate().isEmpty;
        i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Other'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();
    await tester.tap(find.byType(DropdownButton<Locale>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Valencià / Català').last);
    await tester.pumpAndSettle();

    expect(find.text('Configuració'), findsWidgets);

    await tester.tap(find.text('Preferides'));
    await tester.pump();

    for (var i = 0;
        i < 20 &&
            find
                .text('Encara no hi ha pel·lícules preferides.')
                .evaluate()
                .isEmpty;
        i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Pel·lícules preferides'), findsOneWidget);
    expect(
        find.text('Encara no hi ha pel·lícules preferides.'), findsOneWidget);
    expect(find.text('Interstellar'), findsNothing);

    await tester.tap(find.text('Configuració'));
    await tester.pump();
    await tester.tap(find.text('Tancar sessió'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Tester');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Configuración'), findsWidgets);
  });
}
