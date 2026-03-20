import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data source para gestionar la lista negra de carpetas.
/// Utiliza SharedPreferences para persistencia simple de las carpetas bloqueadas.
class BlacklistDatasource {
  static const String _blacklistKey = 'blacklisted_folders';

  /// Carpetas por defecto que se bloquean (aplicaciones de mensajería)
  static const List<String> defaultBlacklistedFolders = [
    'WhatsApp',
    'WhatsApp Audio',
    'WhatsApp Voice Notes',
    'Telegram',
    'Telegram Audio',
    'Signal',
    'Signal Audio',
    'Messenger',
    'Facebook',
    'Instagram',
    'Discord',
    'Slack',
    'Teams',
    'Zoom',
    'Skype',
  ];

  final SharedPreferences _prefs;

  BlacklistDatasource(this._prefs);

  /// Obtiene la lista de carpetas bloqueadas
  List<String> getBlacklistedFolders() {
    return _prefs.getStringList(_blacklistKey) ?? defaultBlacklistedFolders;
  }

  /// Guarda la lista de carpetas bloqueadas
  Future<bool> saveBlacklistedFolders(List<String> folders) {
    return _prefs.setStringList(_blacklistKey, folders);
  }

  /// Añade una carpeta a la lista negra
  Future<bool> addFolderToBlacklist(String folder) async {
    final current = getBlacklistedFolders();
    if (!current.contains(folder)) {
      current.add(folder);
      return saveBlacklistedFolders(current);
    }
    return true;
  }

  /// Elimina una carpeta de la lista negra
  Future<bool> removeFolderFromBlacklist(String folder) async {
    final current = getBlacklistedFolders();
    current.remove(folder);
    return saveBlacklistedFolders(current);
  }

  /// Verifica si una carpeta está en la lista negra
  ///
  /// Usa coincidencia de prefijo para evitar bloquear carpetas de usuario
  /// que contengan palabras de la lista negra (ej: "Music/Telegram" no se bloquea
  /// por "Telegram" pero sí "Telegram Audio")
  bool isFolderBlacklisted(String folder) {
    final blacklisted = getBlacklistedFolders();

    // DEBUG: Log the check
    if (folder.isNotEmpty) {
      debugPrint(
        'DEBUG_BLACKLIST: Verificando folder "$folder" contra blacklist: $blacklisted',
      );
    }

    // Usamos coincidencia de prefijo más específica:
    // - La carpeta de la lista negra debe estar al inicio del path O
    // - Ser una ruta completa como "Telegram Audio"
    final result = blacklisted.any((blocked) {
      final blockedLower = blocked.toLowerCase();
      final folderLower = folder.toLowerCase();

      // 1. Coincidencia exacta (case insensitive)
      if (folderLower == blockedLower) return true;

      // 2. La carpeta bloqueada es prefijo del path (ej: "Telegram Audio" dentro de "Telegram Audio/Subfolder")
      if (folderLower.startsWith('$blockedLower/')) return true;

      // 3. El path termina exactamente con la carpeta bloqueada (ej: path termina en "/Telegram Audio")
      if (folderLower.endsWith('/$blockedLower')) return true;

      // 4. Coincidencia de ruta completa si hay espacios (para "WhatsApp Audio", "Telegram Audio", etc.)
      // Solo si el bloqueado contiene espacio, verificar coincidencia exacta de ese componente
      if (blockedLower.contains(' ')) {
        final pathParts = folderLower.split('/');
        for (final part in pathParts) {
          if (part == blockedLower) return true;
        }
      }

      return false;
    });

    if (result) {
      // Find which blocked item matched
      final matchedItem = blacklisted.firstWhere((blocked) {
        final blockedLower = blocked.toLowerCase();
        final folderLower = folder.toLowerCase();
        return folderLower == blockedLower ||
            folderLower.startsWith('$blockedLower/') ||
            folderLower.endsWith('/$blockedLower');
      }, orElse: () => '');
      debugPrint(
        'DEBUG_BLACKLIST: "$folder" BLOQUEADO por coincidencia con "$matchedItem"',
      );
    }

    return result;
  }

  /// Restablece la lista negra a los valores por defecto
  Future<bool> resetToDefaults() {
    return saveBlacklistedFolders(defaultBlacklistedFolders);
  }
}
