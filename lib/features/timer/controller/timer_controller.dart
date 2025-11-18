import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:focus_app/core/storage/storage_service.dart';

enum TimerMode { focus, shortBreak, longBreak }

const int _focusCyclesBeforeLongBreak = 4;

class TimerController extends ChangeNotifier {
  // --- STATE DURASI YANG DAPAT DISETEL (Dalam detik) ---
  int _focusDuration = 25 * 60;
  int _shortBreakDuration = 5 * 60;
  int _longBreakDuration = 15 * 60;

  // --- STATE TIMER AKTUAL ---
  Timer? _timer;
  int _currentSeconds = 25 * 60;
  bool _isRunning = false;
  int _focusSessionsCompleted = 0;
  TimerMode _currentMode = TimerMode.focus;
  int _focusCycleCount = 0;

  // --- STATE PERSISTENCE ---
  final StorageService _storageService = StorageService();
  final Map<String, int> _dailySessionLogs = {};
  final DateFormat _logKeyFormat = DateFormat('yyyy-MM-dd');

  // --- CONSTRUCTOR ---
  TimerController() {
    loadSettings();
  }

  // --- GETTERS ---
  int get currentSeconds => _currentSeconds;
  bool get isRunning => _isRunning;
  int get focusSessionsCompleted => _focusSessionsCompleted;
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

  String get modeTitle {
    switch (_currentMode) {
      case TimerMode.focus:
        return 'Fokus Belajar';
      case TimerMode.shortBreak:
        return 'Istirahat Pendek';
      case TimerMode.longBreak:
        return 'Istirahat Panjang';
    }
    // PERBAIKAN: Hapus return '' yang menyebabkan dead code
  }

  String get modeDescription {
    switch (_currentMode) {
      case TimerMode.focus:
        return 'Saatnya fokus penuh pada tugas Anda';
      case TimerMode.shortBreak:
        return 'Istirahat Pendek (Pendinginan)';
      case TimerMode.longBreak:
        return 'Istirahat Panjang (Isi Ulang Energi)';
    }
    // PERBAIKAN: Hapus return '' yang menyebabkan dead code
  }

  // --- PERSISTENCE LOGIC ---
  Future<void> loadSettings() async {
    _dailySessionLogs.addAll(await _storageService.loadAllDailySessions());
    notifyListeners();
  }

  Future<void> _logDailySessionCompletion() async {
    final todayKey = _logKeyFormat.format(DateTime.now());
    int currentCount = (_dailySessionLogs[todayKey] ?? 0) + 1;
    _dailySessionLogs[todayKey] = currentCount;

    await _storageService.saveDailySessions(todayKey, currentCount);
    notifyListeners();
  }

  // --- CORE LOGIC ---

  void startStopTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
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

  void _handleModeCompletion() {
    if (_currentMode == TimerMode.focus) {
      _focusSessionsCompleted++;
      _focusCycleCount++;
      _logDailySessionCompletion();

      if (_focusCycleCount >= _focusCyclesBeforeLongBreak) {
        _currentMode = TimerMode.longBreak;
        _currentSeconds = _longBreakDuration;
        _focusCycleCount = 0;
      } else {
        _currentMode = TimerMode.shortBreak;
        _currentSeconds = _shortBreakDuration;
      }
    } else {
      _currentMode = TimerMode.focus;
      _currentSeconds = _focusDuration;
    }
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
