import 'package:button_m3e/button_m3e.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';

import '../../../settings/presentation/providers/flavor_provider.dart';
import '../providers/tag_editor_provider.dart';

/// Pantalla para editar los metadatos (etiquetas) de una pista de audio.
class TagEditorScreen extends ConsumerStatefulWidget {
  final String filePath;

  const TagEditorScreen({super.key, required this.filePath});

  @override
  ConsumerState<TagEditorScreen> createState() => _TagEditorScreenState();
}

class _TagEditorScreenState extends ConsumerState<TagEditorScreen> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  final _yearController = TextEditingController();
  final _trackNumberController = TextEditingController();
  final _genreController = TextEditingController();

  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    // Cargar metadatos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tagEditorProvider.notifier).loadMetadata(widget.filePath);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _yearController.dispose();
    _trackNumberController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  void _initializeControllers(TagEditorState state) {
    if (!_controllersInitialized && state.currentTagEdit != null) {
      _titleController.text = state.currentTagEdit!.title;
      _artistController.text = state.currentTagEdit!.artist;
      _albumController.text = state.currentTagEdit!.album;
      _yearController.text = state.currentTagEdit!.year?.toString() ?? '';
      _trackNumberController.text =
          state.currentTagEdit!.trackNumber?.toString() ?? '';
      _genreController.text = state.currentTagEdit!.genre ?? '';
      _controllersInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final flavor = ref.watch(flavorProvider);
    final tagState = ref.watch(tagEditorProvider);

    // Inicializar controladores cuando se carguen los datos
    _initializeControllers(tagState);

    return Scaffold(
      backgroundColor: flavor.base,
      appBar: AppBar(
        backgroundColor: flavor.base,
        elevation: 0,
        leading: IconButtonM3E(
          variant: IconButtonM3EVariant.standard,
          icon: Icon(Icons.close_rounded, color: flavor.text),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Cerrar',
        ),
        title: Text(
          'Editar Etiquetas',
          style: TextStyle(color: flavor.text, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _buildBody(flavor, tagState),
    );
  }

  Widget _buildBody(Flavor flavor, TagEditorState state) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: flavor.mauve),
            const SizedBox(height: 16),
            Text(
              'Cargando metadatos...',
              style: TextStyle(color: flavor.subtext1),
            ),
          ],
        ),
      );
    }

    if (state.errorMessage != null && state.currentTagEdit == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: flavor.red, size: 64),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: TextStyle(color: flavor.text),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ButtonM3E(
                label: const Text('Reintentar'),
                style: ButtonM3EStyle.tonal,
                onPressed: () {
                  ref
                      .read(tagEditorProvider.notifier)
                      .loadMetadata(widget.filePath);
                },
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título
          _buildTextField(
            controller: _titleController,
            label: 'Título',
            icon: Icons.music_note_rounded,
            flavor: flavor,
            onChanged: (value) {
              ref.read(tagEditorProvider.notifier).updateField(title: value);
            },
          ),
          const SizedBox(height: 16),

          // Artista
          _buildTextField(
            controller: _artistController,
            label: 'Artista',
            icon: Icons.person_rounded,
            flavor: flavor,
            onChanged: (value) {
              ref.read(tagEditorProvider.notifier).updateField(artist: value);
            },
          ),
          const SizedBox(height: 16),

          // Álbum
          _buildTextField(
            controller: _albumController,
            label: 'Álbum',
            icon: Icons.album_rounded,
            flavor: flavor,
            onChanged: (value) {
              ref.read(tagEditorProvider.notifier).updateField(album: value);
            },
          ),
          const SizedBox(height: 16),

          // Año y Número de pista en fila
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _yearController,
                  label: 'Año',
                  icon: Icons.calendar_today_rounded,
                  flavor: flavor,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final year = int.tryParse(value);
                    ref
                        .read(tagEditorProvider.notifier)
                        .updateField(year: year);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _trackNumberController,
                  label: 'Pista #',
                  icon: Icons.tag_rounded,
                  flavor: flavor,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final trackNumber = int.tryParse(value);
                    ref
                        .read(tagEditorProvider.notifier)
                        .updateField(trackNumber: trackNumber);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Género
          _buildTextField(
            controller: _genreController,
            label: 'Género',
            icon: Icons.category_rounded,
            flavor: flavor,
            onChanged: (value) {
              ref.read(tagEditorProvider.notifier).updateField(genre: value);
            },
          ),
          const SizedBox(height: 32),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ButtonM3E(
                  label: const Text('Cancelar'),
                  style: ButtonM3EStyle.outlined,
                  onPressed: state.isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ButtonM3E(
                  label: Text(state.isSaving ? 'Guardando...' : 'Guardar'),
                  style: ButtonM3EStyle.filled,
                  onPressed: state.isSaving ? null : () => _saveChanges(flavor),
                ),
              ),
            ],
          ),

          // Mensaje de éxito
          if (state.saveSuccess) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: flavor.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: flavor.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Metadatos guardados correctamente',
                      style: TextStyle(color: flavor.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Flavor flavor,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: flavor.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: flavor.subtext1),
        prefixIcon: Icon(icon, color: flavor.subtext1),
        filled: true,
        fillColor: flavor.surface1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: flavor.mauve, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      onChanged: onChanged,
    );
  }

  Future<void> _saveChanges(Flavor flavor) async {
    final success = await ref.read(tagEditorProvider.notifier).saveMetadata();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: flavor.base),
              const SizedBox(width: 8),
              Text('Metadatos guardados', style: TextStyle(color: flavor.base)),
            ],
          ),
          backgroundColor: flavor.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Cerrar la pantalla después de guardar
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
    }
  }
}
