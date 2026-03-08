import 'package:button_group_m3e/button_group_m3e.dart';
import 'package:button_m3e/button_m3e.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';

import '../../../library/presentation/providers/library_provider.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
import '../providers/albums_provider.dart';
import '../widgets/album_card.dart';
import '../widgets/album_filter_sheet.dart';

/// Albums screen displaying albums in grid or list view.
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
    // Load albums when screen initializes
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

    // Watch library changes to reload albums
    ref.listen(libraryProvider, (previous, next) {
      if (previous?.tracks != next.tracks) {
        ref.read(albumsProvider.notifier).loadAlbums();
      }
    });

    return SafeArea(
      child: Column(
        children: [
          // =====================
          // 1. HEADER WITH SEARCH
          // =====================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Álbumes',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: flavor.text,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    // Action buttons row
                    Row(
                      children: [
                        // Shuffle button
                        IconButtonM3E(
                          icon: Icon(
                            Icons.shuffle_rounded,
                            color: albumsState.isShuffleEnabled
                                ? flavor.mauve
                                : flavor.subtext1,
                          ),
                          variant: IconButtonM3EVariant.standard,
                          onPressed: () {
                            ref.read(albumsProvider.notifier).toggleShuffle();
                          },
                          tooltip: 'Aleatorio',
                        ),
                        // View mode toggle
                        IconButtonM3E(
                          icon: Icon(
                            albumsState.viewMode == AlbumViewMode.grid
                                ? Icons.view_list_rounded
                                : Icons.grid_view_rounded,
                            color: flavor.subtext1,
                          ),
                          variant: IconButtonM3EVariant.standard,
                          onPressed: () {
                            ref.read(albumsProvider.notifier).toggleViewMode();
                          },
                          tooltip: albumsState.viewMode == AlbumViewMode.grid
                              ? 'Ver como lista'
                              : 'Ver como cuadrícula',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search bar (same as HomeContentScreen)
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
          // 2. FILTER AND SORT BAR
          // =====================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Filter button (text button)
                TextButton.icon(
                  onPressed: () {
                    showAlbumFilterSheet(context);
                  },
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
                const SizedBox(width: 8),
                // Shuffle and View toggle with ButtonGroupM3E
                ButtonGroupM3E(
                  actions: [
                    ButtonGroupM3EAction(
                      label: const SizedBox.shrink(),
                      icon: Icon(
                        Icons.shuffle_rounded,
                        size: 18,
                        color: albumsState.isShuffleEnabled
                            ? flavor.mauve
                            : flavor.subtext1,
                      ),
                      style: albumsState.isShuffleEnabled
                          ? ButtonM3EStyle.filled
                          : ButtonM3EStyle.outlined,
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
                        color: albumsState.viewMode == AlbumViewMode.grid
                            ? flavor.mauve
                            : flavor.subtext1,
                      ),
                      style: albumsState.viewMode == AlbumViewMode.grid
                          ? ButtonM3EStyle.filled
                          : ButtonM3EStyle.outlined,
                      onPressed: () {
                        ref.read(albumsProvider.notifier).toggleViewMode();
                      },
                    ),
                  ],
                  type: ButtonGroupM3EType.connected,
                  shape: ButtonGroupM3EShape.round,
                  size: ButtonGroupM3ESize.sm,
                ),
              ],
            ),
          ),

          // =====================
          // 3. ALBUMS GRID/LIST
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
            // TODO: Navigate to album detail
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
            // TODO: Navigate to album detail
          },
        );
      },
    );
  }
}
