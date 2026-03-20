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
  bool isFolderBlacklisted(String folder) {
    final blacklisted = getBlacklistedFolders();
    // Comprobación exacta o si la carpeta contiene alguna de las rutas bloqueadas
    return blacklisted.any(
      (blocked) =>
        folder.toLowerCase().contains(blocked.toLowerCase()) ||
        blocked.toLowerCase().contains(folder.toLowerCase()),
    );
  }

  /// Restablece la lista negra a los valores por defecto
  Future<bool> resetToDefaults() {
    return saveBlacklistedFolders(defaultBlacklistedFolders);
  }
}
