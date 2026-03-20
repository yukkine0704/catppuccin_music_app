import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/tag_edit.dart';
import '../datasources/tag_editor_datasource.dart';

/// Repositorio para gestionar la edición de etiquetas de audio.
class TagEditorRepository {
  final TagEditorDatasource _datasource;

  TagEditorRepository(this._datasource);

  /// Lee los metadatos de un archivo de audio.
  Future<Either<Failure, TagEdit>> getMetadata(String filePath) {
    return _datasource.readMetadata(filePath);
  }

  /// Guarda los metadatos modificados.
  Future<Either<Failure, void>> saveMetadata(TagEdit tagEdit) {
    return _datasource.writeMetadata(tagEdit);
  }
}
