// lib/features/tasks/model/task.dart

// Hapus import uuid karena tidak dipakai di sini (dipakai di controller)
// import 'package:uuid/uuid.dart';

enum TaskCompletionStatus { onTime, late }

class Task {
  final String id;
  final String title;
  final String description;
  final int pomodoroCount;
  final bool isCompleted;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime? completedAt;
  final TaskCompletionStatus? completionStatus;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.pomodoroCount = 1,
    this.isCompleted = false,
    this.deadline,
    required this.createdAt,
    this.completedAt,
    this.completionStatus,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      pomodoroCount: json['pomodoroCount'] as int,
      isCompleted: json['isCompleted'] as bool,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      completionStatus: json['completionStatus'] != null
          ? TaskCompletionStatus.values.firstWhere(
              (e) =>
                  e.toString() ==
                  'TaskCompletionStatus.${json['completionStatus']}',
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pomodoroCount': pomodoroCount,
      'isCompleted': isCompleted,
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'completionStatus': completionStatus?.name,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    int? pomodoroCount,
    bool? isCompleted,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? completedAt,
    TaskCompletionStatus? completionStatus,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pomodoroCount: pomodoroCount ?? this.pomodoroCount,
      isCompleted: isCompleted ?? this.isCompleted,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      completionStatus: completionStatus ?? this.completionStatus,
    );
  }
}
