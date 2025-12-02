import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends ChangeNotifier {
  // Data Profil
  String _username = 'Pengguna Ocus';
  String _bio = 'Tetap Fokus, Tetap Produktif!';

  // 0: Default, 1: Pria, 2: Wanita
  int _avatarIndex = 0;

  // Data Pengaturan
  bool _enableNotifications = true;
  bool _isDarkMode = true; // Kita simpan status tema di sini untuk UI switch

  // Getters
  String get username => _username;
  String get bio => _bio;
  int get avatarIndex => _avatarIndex;
  bool get enableNotifications => _enableNotifications;
  bool get isDarkMode => _isDarkMode;

  ProfileController() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? 'Pengguna Ocus';
    _bio = prefs.getString('bio') ?? 'Tetap Fokus, Tetap Produktif!';
    _avatarIndex = prefs.getInt('avatarIndex') ?? 0; // Load avatar
    _enableNotifications = prefs.getBool('enableNotifications') ?? true;
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }

  Future<void> updateUsername(String newName) async {
    if (newName.isEmpty) return;
    _username = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newName);
    notifyListeners();
  }

  Future<void> updateBio(String newBio) async {
    if (newBio.isEmpty) return;
    _bio = newBio;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bio', newBio);
    notifyListeners();
  }

  // BARU: Update Avatar
  Future<void> updateAvatar(int index) async {
    _avatarIndex = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('avatarIndex', index);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool isEnabled) async {
    _enableNotifications = isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableNotifications', isEnabled);
    notifyListeners();
  }

  // Toggle Tema (Hanya menyimpan preferensi UI, logika tema ada di main.dart)
  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    notifyListeners();
  }
}
