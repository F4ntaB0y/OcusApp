class Task {
  final String id;
  final String title;
  final String description;
  final int pomodoroCount; // Field ini yang perlu di-update
  final bool isCompleted;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.pomodoroCount = 1,
    this.isCompleted = false,
    this.deadline,
    required this.createdAt,
    this.completedAt,
  });

  // FUNGSI BARU: Konversi objek Task ke Map (JSON)
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'pomodoroCount': pomodoroCount,
    'isCompleted': isCompleted,
    'deadline': deadline?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  // FUNGSI BARU: Buat objek Task dari Map (JSON)
  factory Task.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateString) {
      if (dateString == null) return null;
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }

    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      pomodoroCount: json['pomodoroCount'] as int? ?? 1,
      isCompleted: json['isCompleted'] as bool? ?? false,
      deadline: parseDate(json['deadline'] as String?),
      createdAt: parseDate(json['createdAt'] as String?) ?? DateTime.now(),
      completedAt: parseDate(json['completedAt'] as String?),
    );
  }

  // PERBAIKAN KRITIS: Tambahkan pomodoroCount ke copyWith
  Task copyWith({
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? completedAt,
    int? pomodoroCount, // <-- INI YANG HILANG
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      // Gunakan pomodoroCount yang baru jika disediakan
      pomodoroCount: pomodoroCount ?? this.pomodoroCount,
      isCompleted: isCompleted ?? this.isCompleted,
      deadline: deadline,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }
}
