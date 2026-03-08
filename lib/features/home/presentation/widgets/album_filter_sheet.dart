import 'package:button_group_m3e/button_group_m3e.dart';
import 'package:button_m3e/button_m3e.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/providers/flavor_provider.dart';
import '../providers/albums_provider.dart';

/// Bottom sheet for filtering and sorting albums.
class AlbumFilterSheet extends ConsumerWidget {
  const AlbumFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(flavorProvider);
    final albumsState = ref.watch(albumsProvider);

    return Container(
      decoration: BoxDecoration(
        color: flavor.base,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: flavor.surface0,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Filtrar y ordenar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: flavor.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Filter options
              Text(
                'Ordenar por',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: flavor.subtext1),
              ),
              const SizedBox(height: 12),
              // Filter type buttons
              ButtonGroupM3E(
                actions: [
                  ButtonGroupM3EAction(
                    label: const Text('Nombre'),
                    onPressed: () {
                      ref
                          .read(albumsProvider.notifier)
                          .setFilterType(AlbumFilterType.name);
                    },
                    style: albumsState.filterType == AlbumFilterType.name
                        ? ButtonM3EStyle.filled
                        : ButtonM3EStyle.outlined,
                  ),
                  ButtonGroupM3EAction(
                    label: const Text('Artista'),
                    onPressed: () {
                      ref
                          .read(albumsProvider.notifier)
                          .setFilterType(AlbumFilterType.artist);
                    },
                    style: albumsState.filterType == AlbumFilterType.artist
                        ? ButtonM3EStyle.filled
                        : ButtonM3EStyle.outlined,
                  ),
                  ButtonGroupM3EAction(
                    label: const Text('Año'),
                    onPressed: () {
                      ref
                          .read(albumsProvider.notifier)
                          .setFilterType(AlbumFilterType.year);
                    },
                    style: albumsState.filterType == AlbumFilterType.year
                        ? ButtonM3EStyle.filled
                        : ButtonM3EStyle.outlined,
                  ),
                  ButtonGroupM3EAction(
                    label: const Text('Canciones'),
                    onPressed: () {
                      ref
                          .read(albumsProvider.notifier)
                          .setFilterType(AlbumFilterType.trackCount);
                    },
                    style: albumsState.filterType == AlbumFilterType.trackCount
                        ? ButtonM3EStyle.filled
                        : ButtonM3EStyle.outlined,
                  ),
                  ButtonGroupM3EAction(
                    label: const Text('Fecha'),
                    onPressed: () {
                      ref
                          .read(albumsProvider.notifier)
                          .setFilterType(AlbumFilterType.dateAdded);
                    },
                    style: albumsState.filterType == AlbumFilterType.dateAdded
                        ? ButtonM3EStyle.filled
                        : ButtonM3EStyle.outlined,
                  ),
                ],
                overflow: ButtonGroupM3EOverflow.scroll,
                type: ButtonGroupM3EType.connected,
                shape: ButtonGroupM3EShape.round,
                size: ButtonGroupM3ESize.sm,
                selectedIndex: AlbumFilterType.values.indexOf(
                  albumsState.filterType,
                ),
                equalizeWidths: false,
              ),
              const SizedBox(height: 24),
              // Sort direction
              Text(
                'Dirección',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: flavor.subtext1),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ButtonM3E(
                      onPressed: () {
                        ref
                            .read(albumsProvider.notifier)
                            .setSortDirection(AlbumSortDirection.ascending);
                      },
                      label: const Text('Ascendente'),
                      style:
                          albumsState.sortDirection ==
                              AlbumSortDirection.ascending
                          ? ButtonM3EStyle.filled
                          : ButtonM3EStyle.outlined,
                      icon: const Icon(Icons.arrow_upward_rounded),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ButtonM3E(
                      onPressed: () {
                        ref
                            .read(albumsProvider.notifier)
                            .setSortDirection(AlbumSortDirection.descending);
                      },
                      label: const Text('Descendente'),
                      style:
                          albumsState.sortDirection ==
                              AlbumSortDirection.descending
                          ? ButtonM3EStyle.filled
                          : ButtonM3EStyle.outlined,
                      icon: const Icon(Icons.arrow_downward_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Apply button
              SizedBox(
                width: double.infinity,
                child: ButtonM3E(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  label: const Text('Aplicar'),
                  style: ButtonM3EStyle.filled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the filter bottom sheet.
void showAlbumFilterSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const AlbumFilterSheet(),
  );
}
