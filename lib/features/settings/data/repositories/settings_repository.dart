import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../datasources/shared_prefs_datasource.dart';

/// Repository for app settings.
/// Coordinates data operations for settings persistence.
class SettingsRepository {
  final SharedPrefsDatasource _datasource;

  SettingsRepository(this._datasource);

  /// Gets the current flavor from storage.
  /// Returns Mocha by default if not set or on error.
  Either<Failure, Flavor> getFlavor() {
    final result = _datasource.getFlavorIndex();

    return result.fold(
      (failure) => Left(failure),
      (index) => Right(_getFlavorByIndex(index)),
    );
  }

  /// Saves the selected flavor to storage.
  Either<Failure, void> setFlavor(Flavor flavor) {
    final index = _getFlavorIndex(flavor);
    return _datasource.setFlavorIndex(index);
  }

  /// Converts flavor index to Flavor enum.
  Flavor _getFlavorByIndex(int index) {
    switch (index) {
      case 0:
        return catppuccin.mocha;
      case 1:
        return catppuccin.latte;
      case 2:
        return catppuccin.frappe;
      case 3:
        return catppuccin.macchiato;
      default:
        return catppuccin.mocha;
    }
  }

  /// Converts Flavor enum to index.
  int _getFlavorIndex(Flavor flavor) {
    if (flavor == catppuccin.latte) return 1;
    if (flavor == catppuccin.frappe) return 2;
    if (flavor == catppuccin.macchiato) return 3;
    return 0;
  }
}
