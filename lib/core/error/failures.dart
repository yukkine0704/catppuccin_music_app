import 'package:equatable/equatable.dart';

/// Base failure class for error handling.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure for permission errors.
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Failure for database errors.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Failure for file system errors.
class FileSystemFailure extends Failure {
  const FileSystemFailure(super.message);
}
