import 'package:button_group_m3e/button_group_m3e.dart';
import 'package:button_m3e/button_m3e.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../library/presentation/providers/library_provider.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
import '../providers/albums_provider.dart';
import '../widgets/album_card.dart';
import '../widgets/album_filter_sheet.dart';

/// Pantalla de álbumes que muestra los álbumes en vista de cuadrícula o lista.
class AlbumsScreen extends ConsumerStatefulWidget {
  const AlbumsScreen({super.key});

  @override
  ConsumerState<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends ConsumerState<AlbumsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar álbumes al inicializar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(albumsProvider.notifier).loadAlbums();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flavor = ref.watch(flavorProvider);
    final albumsState = ref.watch(albumsProvider);

    // Escuchar cambios en la biblioteca para recargar
    ref.listen(libraryProvider, (previous, next) {
      if (previous?.tracks != next.tracks) {
        ref.read(albumsProvider.notifier).loadAlbums();
      }
    });

    return SafeArea(
      child: Column(
        children: [
          // =====================
          // 1. CABECERA CON BÚSQUEDA
          // =====================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Álbumes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: flavor.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    ref.read(albumsProvider.notifier).setSearchQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar álbumes...',
                    hintStyle: TextStyle(color: flavor.subtext1),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: flavor.subtext1,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: flavor.subtext1,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(albumsProvider.notifier)
                                  .setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: flavor.surface0,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  style: TextStyle(color: flavor.text),
                ),
              ],
            ),
          ),

          // =====================
          // 2. BARRA DE FILTRO Y GRUPO DE BOTONES (CONNECTED)
          // =====================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón de Filtro
                TextButton.icon(
                  onPressed: () => showAlbumFilterSheet(context),
                  icon: Icon(
                    Icons.filter_list_rounded,
                    color: flavor.mauve,
                    size: 20,
                  ),
                  label: Text(
                    _getFilterLabel(albumsState.filterType),
                    style: TextStyle(
                      color: flavor.mauve,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: flavor.surface0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),

                // ButtonGroupM3E en variante CONNECTED
                // Este diseño reemplaza al antiguo Segmented Button
                ButtonGroupM3E(
                  type: ButtonGroupM3EType.connected,
                  shape: ButtonGroupM3EShape.round,
                  size: ButtonGroupM3ESize.sm,
                  // IMPORTANTE: Activamos selection para forzar bordes rectos internos
                  selection: true,
                  // Usamos un estilo uniforme para que el borde sea continuo
                  style: ButtonM3EStyle.tonal,
                  actions: [
                    ButtonGroupM3EAction(
                      // En lugar de SizedBox.shrink, usamos un widget transparente
                      // o vacío para minimizar el desplazamiento
                      label: const SizedBox.shrink(),
                      icon: Icon(
                        Icons.shuffle_rounded,
                        size: 18,
                        color: albumsState.isShuffleEnabled
                            ? flavor.mauve
                            : flavor.subtext1,
                      ),
                      // El estado se refleja en el color del icono, no en el estilo del botón
                      selected: albumsState.isShuffleEnabled,
                      onPressed: () {
                        ref.read(albumsProvider.notifier).toggleShuffle();
                      },
                    ),
                    ButtonGroupM3EAction(
                      label: const SizedBox.shrink(),
                      icon: Icon(
                        albumsState.viewMode == AlbumViewMode.grid
                            ? Icons.view_list_rounded
                            : Icons.grid_view_rounded,
                        size: 18,
                        color: flavor.subtext1,
                      ),
                      onPressed: () {
                        ref.read(albumsProvider.notifier).toggleViewMode();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // =====================
          // 3. CUADRÍCULA/LISTA DE ÁLBUMES
          // =====================
          Expanded(
            child: albumsState.isLoading
                ? Center(child: CircularProgressIndicator(color: flavor.mauve))
                : albumsState.filteredAlbums.isEmpty
                ? _buildEmptyState(flavor)
                : albumsState.viewMode == AlbumViewMode.grid
                ? _buildGridView(albumsState, flavor)
                : _buildListView(albumsState, flavor),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(AlbumFilterType filterType) {
    switch (filterType) {
      case AlbumFilterType.name:
        return 'Nombre';
      case AlbumFilterType.artist:
        return 'Artista';
      case AlbumFilterType.year:
        return 'Año';
      case AlbumFilterType.trackCount:
        return 'Canciones';
      case AlbumFilterType.dateAdded:
        return 'Fecha';
    }
  }

  Widget _buildEmptyState(Flavor flavor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.album_rounded, size: 64, color: flavor.subtext1),
          const SizedBox(height: 16),
          Text(
            'No se encontraron álbumes',
            style: TextStyle(
              color: flavor.text,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade música a tu biblioteca',
            style: TextStyle(color: flavor.subtext1, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(AlbumsState state, Flavor flavor) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: state.filteredAlbums.length,
      itemBuilder: (context, index) {
        final album = state.filteredAlbums[index];
        return AlbumCard(
          album: album,
          flavor: flavor,
          onTap: () {
            // TODO: Navegar al detalle del álbum
          },
        );
      },
    );
  }

  Widget _buildListView(AlbumsState state, Flavor flavor) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.filteredAlbums.length,
      itemBuilder: (context, index) {
        final album = state.filteredAlbums[index];
        return AlbumListTile(
          album: album,
          flavor: flavor,
          onTap: () {
            // TODO: Navegar al detalle del álbum
          },
        );
      },
    );
  }
}
