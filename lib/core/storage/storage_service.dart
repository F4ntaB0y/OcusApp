import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  final String _keyDailySessions = 'dailySessionLogs';

  Future<void> _saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> _loadData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // Menyimpan integer tunggal (untuk Total Sesi Fokus Global)
  Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<int?> loadInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  // Menyimpan satu hari (dengan membaca data lama dulu)
  Future<void> saveDailySessions(String dateKey, int count) async {
    final Map<String, int> logs = await loadAllDailySessions();
    logs[dateKey] = count;
    await _saveData(_keyDailySessions, json.encode(logs));
  }

  // PERBAIKAN KRITIS: Menghapus SEMUA riwayat sesi harian (untuk Reset Global)
  Future<void> clearAllDailySessions() async {
    // Menimpa data yang ada dengan Map kosong
    await _saveData(_keyDailySessions, json.encode({}));
  }

  Future<Map<String, int>> loadAllDailySessions() async {
    final String? jsonString = await _loadData(_keyDailySessions);
    if (jsonString != null) {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      return decoded.map((key, value) => MapEntry(key, value as int));
    }
    return {};
  }
}
