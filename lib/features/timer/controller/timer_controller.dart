import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focus_app/core/storage/storage_service.dart';
import 'package:focus_app/core/notifications/notification_service.dart';

enum TimerMode { focus, shortBreak, longBreak }

const int _focusCyclesBeforeLongBreak = 4;

class TimerController extends ChangeNotifier {
  int _focusDuration = 25 * 60;
  int _shortBreakDuration = 5 * 60;
  int _longBreakDuration = 15 * 60;

  Timer? _timer;
  int _currentSeconds = 25 * 60;
  bool _isRunning = false;
  int _focusSessionsCompletedTotal = 0;
  TimerMode _currentMode = TimerMode.focus;
  int _focusCycleCount = 0;

  final StorageService _storageService = StorageService();
  final Map<String, int> _dailySessionLogs = {}; // Data di memori
  final DateFormat _logKeyFormat = DateFormat('yyyy-MM-dd');

  TimerController() {
    loadSettings();
  }

  int get currentSeconds => _currentSeconds;
  bool get isRunning => _isRunning;
  int get focusSessionsCompletedTotal => _focusSessionsCompletedTotal;
  int get todayFocusSessionsCompleted {
    final todayKey = _logKeyFormat.format(DateTime.now());
    return _dailySessionLogs[todayKey] ?? 0;
  }

  TimerMode get currentMode => _currentMode;
  int get focusCycleCount => _focusCycleCount;
  int get focusDuration => _focusDuration;
  int get shortBreakDuration => _shortBreakDuration;
  int get longBreakDuration => _longBreakDuration;
  Map<String, int> get dailySessionLogs => _dailySessionLogs;
  static int get focusCyclesBeforeLongBreak => _focusCyclesBeforeLongBreak;

  String get formattedTime {
    int minutes = (_currentSeconds ~/ 60);
    int seconds = (_currentSeconds % 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get modeTitle => switch (_currentMode) {
    TimerMode.focus => 'Fokus Belajar',
    TimerMode.shortBreak => 'Istirahat Pendek',
    TimerMode.longBreak => 'Istirahat Panjang',
  };

  String get modeDescription => switch (_currentMode) {
    TimerMode.focus => 'Saatnya fokus penuh pada tugas Anda',
    TimerMode.shortBreak => 'Istirahat Pendek (Pendinginan)',
    TimerMode.longBreak => 'Istirahat Panjang (Isi Ulang Energi)',
  };

  Future<bool> _shouldPlaySound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('enableNotifications') ?? true;
  }

  Future<void> loadSettings() async {
    _dailySessionLogs.addAll(await _storageService.loadAllDailySessions());
    _focusSessionsCompletedTotal =
        await _storageService.loadInt('totalFocusSessions') ?? 0;
    notifyListeners();
  }

  Future<void> _logDailySessionCompletion() async {
    final todayKey = _logKeyFormat.format(DateTime.now());
    int currentCount = (_dailySessionLogs[todayKey] ?? 0) + 1;
    _dailySessionLogs[todayKey] = currentCount; // Update memori

    await _storageService.saveDailySessions(
      todayKey,
      currentCount,
    ); // Simpan ke disk

    _focusSessionsCompletedTotal++;
    await _storageService.saveInt(
      'totalFocusSessions',
      _focusSessionsCompletedTotal,
    );

    notifyListeners();
  }

  Future<void> resetTodayFocusSessions() async {
    final todayKey = _logKeyFormat.format(DateTime.now());
    int sessionToday = _dailySessionLogs[todayKey] ?? 0;

    if (sessionToday > 0) {
      _focusSessionsCompletedTotal -= sessionToday;
      if (_focusSessionsCompletedTotal < 0) _focusSessionsCompletedTotal = 0;
      await _storageService.saveInt(
        'totalFocusSessions',
        _focusSessionsCompletedTotal,
      );
    }

    _dailySessionLogs[todayKey] = 0; // Reset memori
    await _storageService.saveDailySessions(todayKey, 0); // Simpan ke disk

    notifyListeners();
  }

  // PERBAIKAN: Menggunakan clearAllDailySessions untuk menghapus total riwayat diagram
  Future<void> resetTotalFocusSessions() async {
    // 1. Reset Counter Global
    _focusSessionsCompletedTotal = 0;
    await _storageService.saveInt('totalFocusSessions', 0);

    // 2. Reset Memori (Map)
    _dailySessionLogs.clear();

    // 3. Reset Disk (Timpa dengan kosong)
    await _storageService.clearAllDailySessions();

    notifyListeners();
  }

  void startStopTimer() {
    if (_isRunning) {
      _stopTimer();
      NotificationService.showNotification(
        id: 1,
        title: modeTitle,
        body: 'Dijeda. Tekan untuk Lanjut.',
        isRunning: false,
        payload: 'timer_paused',
        playSound: false,
      );
    } else {
      _startTimer();
      NotificationService.showNotification(
        id: 1,
        title: modeTitle,
        body: 'Sedang berjalan. Waktu: $formattedTime',
        isRunning: true,
        payload: 'timer_running',
        playSound: false,
      );
    }
    notifyListeners();
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _stopTimer() {
    _isRunning = false;
    _timer?.cancel();
  }

  void _tick(Timer timer) {
    if (_currentSeconds > 0) {
      _currentSeconds--;
    } else {
      _stopTimer();
      _handleModeCompletion();
    }
    notifyListeners();
  }

  void _handleModeCompletion() async {
    final bool playSound = await _shouldPlaySound();

    String notificationTitle;
    String notificationBody;

    if (_currentMode == TimerMode.focus) {
      _focusCycleCount++;
      _logDailySessionCompletion();

      if (_focusCycleCount >= _focusCyclesBeforeLongBreak) {
        _currentMode = TimerMode.longBreak;
        _currentSeconds = _longBreakDuration;
        _focusCycleCount = 0;
        notificationBody =
            'Mulai Istirahat Panjang (${(_longBreakDuration / 60).round()} Menit).';
      } else {
        _currentMode = TimerMode.shortBreak;
        _currentSeconds = _shortBreakDuration;
        notificationBody =
            'Mulai Istirahat Pendek (${(_shortBreakDuration / 60).round()} Menit).';
      }
      notificationTitle = 'Waktu Fokus HABIS!';
    } else {
      _currentMode = TimerMode.focus;
      _currentSeconds = _focusDuration;
      notificationTitle = 'Istirahat Selesai!';
      notificationBody =
          'Saatnya kembali Fokus (${(_focusDuration / 60).round()} Menit).';
    }

    NotificationService.showNotification(
      id: 1,
      title: notificationTitle,
      body: notificationBody,
      isRunning: false,
      payload: 'timer_complete',
      playSound: playSound,
    );

    notifyListeners();
  }

  void resetTimer() {
    _stopTimer();
    _currentMode = TimerMode.focus;
    _currentSeconds = _focusDuration;
    _focusCycleCount = 0;
    notifyListeners();
  }

  void skipMode() {
    _stopTimer();
    _currentSeconds = 0;
    _handleModeCompletion();
    notifyListeners();
  }

  void setDurations({
    required int focusMinutes,
    required int shortBreakMinutes,
    required int longBreakMinutes,
  }) {
    if (!_isRunning) {
      _focusDuration = focusMinutes * 60;
      _shortBreakDuration = shortBreakMinutes * 60;
      _longBreakDuration = longBreakMinutes * 60;

      if (_currentMode == TimerMode.focus) {
        _currentSeconds = _focusDuration;
      } else if (_currentMode == TimerMode.shortBreak) {
        _currentSeconds = _shortBreakDuration;
      } else if (_currentMode == TimerMode.longBreak) {
        _currentSeconds = _longBreakDuration;
      }

      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
