import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/pelicula.dart';
import '../state/app_state.dart';
import '../widgets/pelicula_card.dart';
import 'add_pelicula_screen.dart';
import 'detalle_pelicula_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;
  final String title;
  final bool onlyFavorites;
  final bool showAddButton;

  // Crea una pantalla de listado de películas.
  const HomeScreen({
    super.key,
    required this.user,
    this.title = '',
    this.onlyFavorites = false,
    this.showAddButton = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  String searchText = '';

  @override
  // Libera el controlador de búsqueda.
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Abre la pantalla para añadir una película.
  Future<void> abrirAltaPelicula() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPeliculaScreen(user: widget.user),
      ),
    );
  }

  // Abre el detalle de la película seleccionada.
  Future<void> abrirDetalle(Pelicula pelicula) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetallePeliculaScreen(
          pelicula: pelicula,
          user: widget.user,
        ),
      ),
    );
  }

  // Actualiza el texto usado para filtrar el listado.
  void buscarPeliculas(String value) {
    setState(() {
      searchText = value.trim().toLowerCase();
    });
  }

  // Muestra el listado de películas o favoritas.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenTitle = widget.title.isNotEmpty
        ? widget.title
        : widget.onlyFavorites
            ? l10n.text('favoriteMovies')
            : l10n.text('moviesList');
    final emptyMessage =
        widget.onlyFavorites ? l10n.text('noFavorites') : l10n.text('noMovies');
    final appState = context.watch<AppState>();
    final listState =
        widget.onlyFavorites ? appState.favoriteMovies : appState.allMovies;
    final peliculasFiltradas = searchText.isEmpty
        ? listState.peliculas
        : listState.peliculas
            .where(
              (pelicula) => pelicula.titulo.toLowerCase().contains(searchText),
            )
            .toList();
    final listIsEmpty = listState.peliculas.isEmpty;
    final filteredListIsEmpty = peliculasFiltradas.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.account_circle),
                const SizedBox(width: 6),
                Text(widget.user.name),
              ],
            ),
          ),
        ],
      ),
      body: listState.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: l10n.text('searchMovie'),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchText.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                searchController.clear();
                                buscarPeliculas('');
                              },
                              icon: const Icon(Icons.clear),
                            ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: buscarPeliculas,
                  ),
                ),
                Expanded(
                  child: listIsEmpty
                      ? Center(child: Text(emptyMessage))
                      : filteredListIsEmpty
                          ? Center(child: Text(l10n.text('noSearchResults')))
                          : ListView.builder(
                              itemCount: peliculasFiltradas.length,
                              itemBuilder: (context, index) {
                                final pelicula = peliculasFiltradas[index];
                                final media =
                                    listState.medias[pelicula.id] ?? 0.0;

                                return PeliculaCard(
                                  pelicula: pelicula,
                                  media: media,
                                  onTap: () => abrirDetalle(pelicula),
                                );
                              },
                            ),
                ),
              ],
            ),
      floatingActionButton: widget.showAddButton
          ? FloatingActionButton(
              onPressed: abrirAltaPelicula,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
