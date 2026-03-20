import 'package:button_group_m3e/button_group_m3e.dart';
import 'package:button_m3e/button_m3e.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../library/presentation/providers/library_provider.dart';
import '../../../settings/presentation/providers/flavor_provider.dart';
import '../widgets/search_result_tile.dart';

/// Search screen with real-time search and filter chips.
/// Supports filtering by: All, Artists, Albums, Songs
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    // Auto-focus the search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flavor = ref.watch(flavorProvider);
    final query = ref.watch(searchQueryProvider);
    final filter = ref.watch(searchFilterProvider);
    final tracks = ref.watch(filteredTracksProvider);
    final artists = ref.watch(searchedArtistsProvider);
    final albums = ref.watch(searchedAlbumsProvider);

    return Scaffold(
      backgroundColor: flavor.base,
      appBar: AppBar(
        backgroundColor: flavor.base,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: flavor.text),
          onPressed: () {
            // Clear search when leaving
            ref.read(searchQueryProvider.notifier).state = '';
            ref.read(debouncedSearchQueryProvider.notifier).state = '';
            ref.read(searchFilterProvider.notifier).state =
                SearchFilterType.all;
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Buscar',
          style: TextStyle(color: flavor.text, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSearchBar(flavor),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildFilterChips(flavor, filter),
          ),

          const SizedBox(height: 8),

          // Results
          Expanded(
            child: _buildResults(
              flavor,
              query,
              filter,
              tracks,
              artists,
              albums,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Flavor flavor) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: flavor.surface0,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: flavor.surface1, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search_rounded, color: flavor.subtext1, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
                // Debounce search
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (value == ref.read(searchQueryProvider)) {
                    ref.read(debouncedSearchQueryProvider.notifier).state =
                        value;
                  }
                });
              },
              style: TextStyle(color: flavor.text, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Buscar canciones, artistas, álbumes...',
                hintStyle: TextStyle(color: flavor.subtext1, fontSize: 16),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close_rounded, color: flavor.subtext1, size: 20),
              onPressed: () {
                _controller.clear();
                ref.read(searchQueryProvider.notifier).state = '';
                ref.read(debouncedSearchQueryProvider.notifier).state = '';
              },
              tooltip: 'Limpiar',
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChips(Flavor flavor, SearchFilterType currentFilter) {
    return ButtonGroupM3E(
      actions: [
        ButtonGroupM3EAction(
          label: const Text('Todo'),
          style: currentFilter == SearchFilterType.all
              ? ButtonM3EStyle.filled
              : ButtonM3EStyle.outlined,
          onPressed: () {
            ref.read(searchFilterProvider.notifier).state =
                SearchFilterType.all;
          },
        ),
        ButtonGroupM3EAction(
          label: const Text('Artistas'),
          style: currentFilter == SearchFilterType.artists
              ? ButtonM3EStyle.filled
              : ButtonM3EStyle.outlined,
          onPressed: () {
            ref.read(searchFilterProvider.notifier).state =
                SearchFilterType.artists;
          },
        ),
        ButtonGroupM3EAction(
          label: const Text('Álbumes'),
          style: currentFilter == SearchFilterType.albums
              ? ButtonM3EStyle.filled
              : ButtonM3EStyle.outlined,
          onPressed: () {
            ref.read(searchFilterProvider.notifier).state =
                SearchFilterType.albums;
          },
        ),
        ButtonGroupM3EAction(
          label: const Text('Canciones'),
          style: currentFilter == SearchFilterType.songs
              ? ButtonM3EStyle.filled
              : ButtonM3EStyle.outlined,
          onPressed: () {
            ref.read(searchFilterProvider.notifier).state =
                SearchFilterType.songs;
          },
        ),
      ],
      type: ButtonGroupM3EType.connected,
      shape: ButtonGroupM3EShape.round,
      size: ButtonGroupM3ESize.sm,
      selectedIndex: SearchFilterType.values.indexOf(currentFilter),
    );
  }

  Widget _buildResults(
    Flavor flavor,
    String query,
    SearchFilterType filter,
    List tracks,
    List<String> artists,
    List<String> albums,
  ) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 64, color: flavor.subtext1),
            const SizedBox(height: 16),
            Text(
              'Escribe para buscar',
              style: TextStyle(color: flavor.subtext1, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (filter == SearchFilterType.artists) {
      if (artists.isEmpty) {
        return _buildNoResults(flavor);
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: artists.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: flavor.mauve,
              child: Icon(Icons.person_rounded, color: flavor.base),
            ),
            title: Text(artists[index], style: TextStyle(color: flavor.text)),
            onTap: () {
              // TODO: Navigate to artist page
            },
          );
        },
      );
    }

    if (filter == SearchFilterType.albums) {
      if (albums.isEmpty) {
        return _buildNoResults(flavor);
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: flavor.surface1,
              child: Icon(Icons.album_rounded, color: flavor.mauve),
            ),
            title: Text(albums[index], style: TextStyle(color: flavor.text)),
            onTap: () {
              // TODO: Navigate to album page
            },
          );
        },
      );
    }

    // Songs (or all)
    if (tracks.isEmpty) {
      return _buildNoResults(flavor);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        return SearchResultTile(track: tracks[index], flavor: flavor);
      },
    );
  }

  Widget _buildNoResults(Flavor flavor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: flavor.subtext1),
          const SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: TextStyle(color: flavor.subtext1, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
