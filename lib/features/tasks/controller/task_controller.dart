import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:collection';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/task.dart';

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
      // Data contoh awal
      _tasks.addAll([
        Task(
          id: _uuid.v4(),
          title: 'Setup Environment Flutter Baru',
          description:
              'Pastikan Flutter SDK, VSCode, dan Android Studio sudah terinstal dengan benar.',
          pomodoroCount: 2,
          isCompleted: false,
          deadline: DateTime.now().add(const Duration(days: 3)),
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          completedAt: null,
        ),
        Task(
          id: _uuid.v4(),
          title: 'Baca E-book Clean Code Bab 1-3',
          description: 'Fokus pada prinsip penamaan variabel dan fungsi.',
          pomodoroCount: 1,
          isCompleted: false,
          deadline: DateTime.now().add(const Duration(hours: 5)),
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          completedAt: null,
        ),
      ]);
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
    int? pomodoroCount, // Parameter ini sekarang valid di copyWith
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

      _tasks[index] = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
      );

      if (_tasks[index].isCompleted) {
        final completedTask = _tasks.removeAt(index);
        _tasks.add(completedTask);
      }

      notifyListeners();
      _saveTasks();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
    _saveTasks();
  }
}
