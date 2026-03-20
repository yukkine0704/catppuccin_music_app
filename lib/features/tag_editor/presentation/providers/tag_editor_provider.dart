import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../data/repositories/tag_editor_repository_impl.dart';
import '../../domain/entities/tag_edit.dart';

/// Estado del Tag Editor
class TagEditorState {
  final bool isLoading;
  final TagEdit? currentTagEdit;
  final String? errorMessage;
  final bool isSaving;
  final bool saveSuccess;

  const TagEditorState({
    this.isLoading = false,
    this.currentTagEdit,
    this.errorMessage,
    this.isSaving = false,
    this.saveSuccess = false,
  });

  TagEditorState copyWith({
    bool? isLoading,
    TagEdit? currentTagEdit,
    String? errorMessage,
    bool? isSaving,
    bool? saveSuccess,
  }) {
    return TagEditorState(
      isLoading: isLoading ?? this.isLoading,
      currentTagEdit: currentTagEdit ?? this.currentTagEdit,
      errorMessage: errorMessage,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }
}

/// Provider para el Tag Editor
class TagEditorNotifier extends StateNotifier<TagEditorState> {
  final TagEditorRepository _repository;

  TagEditorNotifier(this._repository) : super(const TagEditorState());

  /// Carga los metadatos de un archivo
  Future<void> loadMetadata(String filePath) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getMetadata(filePath);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (tagEdit) {
        state = state.copyWith(isLoading: false, currentTagEdit: tagEdit);
      },
    );
  }

  /// Actualiza un campo específico
  void updateField({
    String? title,
    String? artist,
    String? album,
    int? year,
    int? trackNumber,
    String? genre,
  }) {
    final current = state.currentTagEdit;
    if (current == null) return;

    state = state.copyWith(
      currentTagEdit: current.copyWith(
        title: title,
        artist: artist,
        album: album,
        year: year,
        trackNumber: trackNumber,
        genre: genre,
      ),
    );
  }

  /// Guarda los metadatos modificados
  Future<bool> saveMetadata() async {
    final current = state.currentTagEdit;
    if (current == null) return false;

    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      saveSuccess: false,
    );

    final result = await _repository.saveMetadata(current);

    return result.fold(
      (failure) {
        state = state.copyWith(isSaving: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isSaving: false, saveSuccess: true);
        return true;
      },
    );
  }

  /// Reinicia el estado
  void reset() {
    state = const TagEditorState();
  }
}

/// Provider para el TagEditorRepository
final tagEditorRepositoryProvider = Provider<TagEditorRepository>((ref) {
  return GetIt.instance<TagEditorRepository>();
});

/// Provider para el TagEditorNotifier
final tagEditorProvider =
    StateNotifierProvider<TagEditorNotifier, TagEditorState>((ref) {
      final repository = ref.watch(tagEditorRepositoryProvider);
      return TagEditorNotifier(repository);
    });
