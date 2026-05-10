import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/opinion.dart';
import '../models/pelicula.dart';
import '../repositories/opinion_repository.dart';
import '../state/app_state.dart';
import '../widgets/caratula_image.dart';
import '../widgets/estrella_rating.dart';
import '../widgets/opinion_tile.dart';
import 'add_opinion_screen.dart';

class DetallePeliculaScreen extends StatefulWidget {
  final Pelicula pelicula;
  final AppUser user;

  // Crea la pantalla de detalle de una película.
  const DetallePeliculaScreen({
    super.key,
    required this.pelicula,
    required this.user,
  });

  @override
  State<DetallePeliculaScreen> createState() => _DetallePeliculaScreenState();
}

class _DetallePeliculaScreenState extends State<DetallePeliculaScreen> {
  final OpinionRepository opinionRepository = OpinionRepository();

  List<Opinion> opiniones = [];
  double media = 0.0;

  // Carga las opiniones al abrir la pantalla.
  @override
  void initState() {
    super.initState();
    cargarOpiniones();
  }

  // Obtiene opiniones y media de valoración.
  Future<void> cargarOpiniones() async {
    final data =
        await opinionRepository.getOpinionesByPelicula(widget.pelicula.id!);
    final mediaCalculada =
        await opinionRepository.getMediaValoracion(widget.pelicula.id!);

    setState(() {
      opiniones = data;
      media = mediaCalculada;
    });
  }

  // Abre la pantalla para añadir una opinión.
  Future<void> abrirAltaOpinion() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddOpinionScreen(peliculaId: widget.pelicula.id!),
      ),
    );
    cargarOpiniones();
  }

  // Marca o desmarca la película como favorita.
  Future<void> cambiarFavorita() async {
    await context.read<AppState>().toggleFavorite(_peliculaActual(context));
  }

  // Pide confirmación y borra la película si el usuario acepta.
  Future<void> confirmarBorrado() async {
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.text('deleteMovieTitle')),
          content: Text(l10n.text('deleteMovieMessage')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.text('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.text('delete')),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    await context.read<AppState>().deleteMovie(_peliculaActual(context));
    if (!mounted) return;
    Navigator.pop(context);
  }

  // Busca la versión más actual de la película en el estado global.
  Pelicula _peliculaActual(BuildContext context) {
    final appState = context.read<AppState>();
    return appState.allMovies.peliculas.firstWhere(
      (pelicula) => pelicula.id == widget.pelicula.id,
      orElse: () => widget.pelicula,
    );
  }

  // Muestra los datos, opiniones y acciones de la película.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final peliculaActual =
        context.watch<AppState>().allMovies.peliculas.firstWhere(
              (pelicula) => pelicula.id == widget.pelicula.id,
              orElse: () => widget.pelicula,
            );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pelicula.titulo),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                const Icon(Icons.account_circle),
                const SizedBox(width: 6),
                Text(widget.user.name),
              ],
            ),
          ),
          IconButton(
            onPressed: cambiarFavorita,
            icon: Icon(
              peliculaActual.favorita ? Icons.star : Icons.star_border,
            ),
            tooltip: peliculaActual.favorita
                ? l10n.text('removeFavorite')
                : l10n.text('markFavorite'),
          ),
          IconButton(
            onPressed: confirmarBorrado,
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.text('deleteMovie'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CaratulaImage(
                  path: widget.pelicula.caratula,
                  width: 180,
                  height: 250,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.pelicula.titulo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Director: ${widget.pelicula.director}'),
              Text('Año: ${widget.pelicula.anio}'),
              Text('Género: ${widget.pelicula.genero}'),
              const SizedBox(height: 12),
              const Text(
                'Sinopsis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(widget.pelicula.sinopsis),
              const SizedBox(height: 16),
              Row(
                children: [
                  EstrellaRating(rating: media, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    media.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Opiniones',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: abrirAltaOpinion,
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Añadir'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              opiniones.isEmpty
                  ? const Text('Todavía no hay opiniones para esta película.')
                  : Column(
                      children: opiniones
                          .map((opinion) => OpinionTile(opinion: opinion))
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
