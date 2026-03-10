import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';

/// Data source for SharedPreferences operations.
/// Handles persistence of app settings like flavor selection.
class SharedPrefsDatasource {
  final SharedPreferences _prefs;

  static const String _flavorIndexKey = 'flavorIndex';

  SharedPrefsDatasource(this._prefs);

  /// Gets the saved flavor index from SharedPreferences.
  /// Returns 0 (Mocha) by default if not set.
  Either<Failure, int> getFlavorIndex() {
    try {
      final index = _prefs.getInt(_flavorIndexKey) ?? 0;
      return Right(index);
    } catch (e) {
      return Left(DatabaseFailure('Failed to read flavor index: $e'));
    }
  }

  /// Saves the flavor index to SharedPreferences.
  Either<Failure, void> setFlavorIndex(int index) {
    try {
      _prefs.setInt(_flavorIndexKey, index);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save flavor index: $e'));
    }
  }
}
