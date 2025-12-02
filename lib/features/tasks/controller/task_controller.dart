import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:collection';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/task.dart'; // <-- Pastikan ini mengimpor TaskCompletionStatus

class TaskController extends ChangeNotifier {
  static const Uuid _uuid = Uuid();
  static const String _tasksKey = 'tasks';

  final List<Task> _tasks = [];

  TaskController() {
    _loadTasks();
  }

  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);
  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  // GETTERS UNTUK STATISTIK TEPAT WAKTU/TERLAMBAT (Total Global)
  List<Task> get allCompletedTasks =>
      _tasks.where((task) => task.isCompleted).toList();
  List<Task> get onTimeCompletedTasks => allCompletedTasks
      .where((task) => task.completionStatus == TaskCompletionStatus.onTime)
      .toList();
  List<Task> get lateCompletedTasks => allCompletedTasks
      .where((task) => task.completionStatus == TaskCompletionStatus.late)
      .toList();

  int get totalTasksCompleted => allCompletedTasks.length;
  int get totalTasksOnTime => onTimeCompletedTasks.length;
  int get totalTasksLate => lateCompletedTasks.length;

  // PERBAIKAN: Getter untuk Tugas Selesai Harian (Filter berdasarkan completedAt hari ini)
  int get todayCompletedTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _tasks.where((task) {
      if (task.isCompleted && task.completedAt != null) {
        final completionDate = DateTime(
          task.completedAt!.year,
          task.completedAt!.month,
          task.completedAt!.day,
        );
        return completionDate == today;
      }
      return false;
    }).length;
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      _tasks.map((task) => task.toJson()).toList(),
    );
    await prefs.setString(_tasksKey, jsonString);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_tasksKey);

    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _tasks.clear();
      _tasks.addAll(
        jsonList
            .map((json) => Task.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } else {
      _tasks.clear();
    }

    notifyListeners();
  }

  void addTask(
    String title, {
    String description = '',
    DateTime? deadline,
    int pomodoroCount = 1,
  }) {
    final newTask = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      deadline: deadline,
      isCompleted: false,
      createdAt: DateTime.now(),
      completedAt: null,
      pomodoroCount: pomodoroCount,
      completionStatus: null,
    );
    _tasks.add(newTask);
    notifyListeners();
    _saveTasks();
  }

  void updateTask({
    required String id,
    String? title,
    String? description,
    DateTime? deadline,
    int? pomodoroCount,
  }) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        title: title,
        description: description,
        deadline: deadline,
        pomodoroCount: pomodoroCount,
      );
      notifyListeners();
      _saveTasks();
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final bool becomingCompleted = !task.isCompleted;

      TaskCompletionStatus? status;
      DateTime? completionTime;

      if (becomingCompleted) {
        completionTime = DateTime.now();
        if (task.deadline != null && completionTime.isAfter(task.deadline!)) {
          status = TaskCompletionStatus.late; // TERLAMBAT
        } else {
          status = TaskCompletionStatus.onTime; // TEPAT WAKTU
        }
      } else {
        status = null;
        completionTime = null;
      }

      _tasks[index] = task.copyWith(
        isCompleted: becomingCompleted,
        completedAt: completionTime,
        completionStatus: status,
      );

      if (_tasks[index].isCompleted) {
        final completedTask = _tasks.removeAt(index);
        _tasks.add(completedTask);
      }

      notifyListeners();
      _saveTasks();
    }
  }

  void resetAllCompletedTasksStatus() {
    for (var i = 0; i < _tasks.length; i++) {
      if (_tasks[i].isCompleted) {
        _tasks[i] = _tasks[i].copyWith(
          isCompleted: false,
          completedAt: null,
          completionStatus: null,
        );
      }
    }
    _tasks.sort(
      (a, b) => a.isCompleted == b.isCompleted ? 0 : (a.isCompleted ? 1 : -1),
    );

    notifyListeners();
    _saveTasks();
  }

  void deleteAllCompletedTasks() {
    _tasks.removeWhere((task) => task.isCompleted);
    notifyListeners();
    _saveTasks();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
    _saveTasks();
  }
}
