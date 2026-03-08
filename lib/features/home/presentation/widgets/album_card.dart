import 'dart:io';

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/album.dart';

/// Album card widget for grid view.
class AlbumCard extends StatelessWidget {
  final Album album;
  final Flavor flavor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const AlbumCard({
    super.key,
    required this.album,
    required this.flavor,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album cover
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: flavor.surface0,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildCoverImage(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Album name
          Text(
            album.name,
            style: TextStyle(
              color: flavor.text,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Artist name
          Text(
            album.artist,
            style: TextStyle(color: flavor.subtext1, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    if (album.albumArtBytes != null) {
      return Image.memory(
        album.albumArtBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    if (album.albumArtPath != null) {
      return Image.file(
        File(album.albumArtPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            flavor.mauve.withValues(alpha: 0.4),
            flavor.pink.withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.album_rounded,
          color: flavor.text.withValues(alpha: 0.6),
          size: 48,
        ),
      ),
    );
  }
}

/// Album list tile widget for list view.
class AlbumListTile extends StatelessWidget {
  final Album album;
  final Flavor flavor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const AlbumListTile({
    super.key,
    required this.album,
    required this.flavor,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            // Album cover
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: flavor.surface0,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildCoverImage(),
              ),
            ),
            const SizedBox(width: 12),
            // Album info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: TextStyle(
                      color: flavor.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    album.artist,
                    style: TextStyle(color: flavor.subtext1, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (album.year != null || album.trackCount > 0)
                    Text(
                      _buildSubtitle(),
                      style: TextStyle(color: flavor.subtext0, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Track count
            if (album.trackCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: flavor.surface0,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${album.trackCount}',
                  style: TextStyle(color: flavor.subtext1, fontSize: 11),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (album.year != null) {
      parts.add('${album.year}');
    }
    if (album.trackCount > 0) {
      parts.add('${album.trackCount} songs');
    }
    return parts.join(' • ');
  }

  Widget _buildCoverImage() {
    if (album.albumArtBytes != null) {
      return Image.memory(
        album.albumArtBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    if (album.albumArtPath != null) {
      return Image.file(
        File(album.albumArtPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            flavor.mauve.withValues(alpha: 0.4),
            flavor.pink.withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.album_rounded,
          color: flavor.text.withValues(alpha: 0.6),
          size: 24,
        ),
      ),
    );
  }
}
