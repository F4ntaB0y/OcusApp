import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart' as table_calendar;
import 'package:intl/intl.dart';
import 'package:focus_app/core/theme/app_colors.dart';
import '../tasks/controller/task_controller.dart';
import '../tasks/model/task.dart';
import '../timer/controller/timer_controller.dart' as timer_ctrl;
import '../tasks/add_edit_task_page.dart';
import 'dart:math'; // Diperlukan untuk fungsi max()

// --- MOLECULE: Stat Card ---
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onReset;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 36),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (onReset != null)
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.red.shade400),
                onPressed: onReset,
              ),
          ],
        ),
      ),
    );
  }
}

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  // Fields
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  late final ValueNotifier<List<Task>> _selectedEvents;

  final Map<DateTime, List<Task>> _tasksByDay = {};

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getTasksForDay(_selectedDay!));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<timer_ctrl.TimerController>().loadSettings();
      _groupTasks(context.read<TaskController>());
      _selectedEvents.value = _getTasksForDay(_selectedDay!);
    });
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  DateTime _normalizeDate(DateTime day) {
    return DateTime(day.year, day.month, day.day);
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _tasksByDay[_normalizeDate(day)] ?? [];
  }

  void _groupTasks(TaskController controller) {
    _tasksByDay.clear();
    for (var task in [
      ...controller.pendingTasks,
      ...controller.completedTasks,
    ]) {
      if (task.deadline != null) {
        final normalizedDay = _normalizeDate(task.deadline!);

        if (_tasksByDay[normalizedDay] == null) {
          _tasksByDay[normalizedDay] = [];
        }
        _tasksByDay[normalizedDay]!.add(task);
      }
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!table_calendar.isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getTasksForDay(selectedDay);
      });
    }
  }

  void _showTaskDetailsDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String status = task.isCompleted ? 'Selesai' : 'Tertunda';
        Color statusColor = task.isCompleted
            ? Colors.green.shade400
            : AppColors.primary;

        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            task.title,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Status: $status',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.grey),
                const Text(
                  'Deskripsi:',
                  style: TextStyle(color: AppColors.primary, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  task.description.isEmpty
                      ? 'Tidak ada deskripsi.'
                      : task.description,
                  style: TextStyle(color: Colors.grey.shade400),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Deadline:',
                  style: TextStyle(color: AppColors.primary, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  task.deadline == null
                      ? 'Tidak ada'
                      : DateFormat(
                          'EEEE, d MMMM yyyy HH:mm',
                          'id_ID',
                        ).format(task.deadline!),
                  style: TextStyle(color: Colors.grey.shade400),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Sesi Pomodoro:',
                  style: TextStyle(color: AppColors.primary, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  task.pomodoroCount.toString(),
                  style: TextStyle(color: Colors.grey.shade400),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Dibuat:',
                  style: TextStyle(color: AppColors.primary, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  DateFormat(
                    'EEEE, d MMMM yyyy HH:mm',
                    'id_ID',
                  ).format(task.createdAt),
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => AddEditTaskPage(taskToEdit: task),
                  ),
                );
              },
              child: const Text(
                'Edit',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  // PERBAIKAN: Menggunakan data riil dari dailySessionLogs
  Widget _buildWeeklyBarChart(
    BuildContext context,
    timer_ctrl.TimerController controller,
  ) {
    // Format tanggal untuk kunci log (harus sama dengan di TimerController)
    final DateFormat logKeyFormat = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();

    // 1. Tentukan awal minggu (Senin)
    int daysToSubtract = now.weekday - 1;
    DateTime startOfWeek = _normalizeDate(
      now.subtract(Duration(days: daysToSubtract)),
    );

    final List<int> weeklySessions = [];
    final Map<String, int> dailyLogs = controller.dailySessionLogs; // Data riil

    // 2. Kumpulkan data sesi untuk 7 hari ini (Senin - Minggu)
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dateKey = logKeyFormat.format(date);
      final sessions =
          dailyLogs[dateKey] ?? 0; // Ambil sesi aktual, atau 0 jika tidak ada
      weeklySessions.add(sessions);
    }

    // 3. Hitung nilai maksimum untuk skala chart
    const maxChartHeight = 100.0;
    // Mencari nilai tertinggi dalam seminggu untuk normalisasi tinggi bar
    int maxDataValue = weeklySessions.reduce(max);
    if (maxDataValue == 0) maxDataValue = 1; // Cegah pembagian dengan nol

    final totalWeeklySessions = weeklySessions.reduce((a, b) => a + b);

    if (totalWeeklySessions == 0) {
      return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 20),
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Belum ada aktivitas minggu ini.',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    const List<String> days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diagram Aktivitas Minggu Ini (Sesi Fokus)',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final sessions = weeklySessions[index];
              // Hitung tinggi bar relatif terhadap nilai maksimum minggu ini
              final height = (sessions / maxDataValue) * maxChartHeight;

              // Tandai hari ini
              bool isToday = table_calendar.isSameDay(
                _normalizeDate(now),
                _normalizeDate(startOfWeek.add(Duration(days: index))),
              );
              Color barColor = isToday
                  ? Colors.green.shade400
                  : AppColors.primary;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sessions.toString(),
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 20,
                    height: height.clamp(
                      5.0,
                      maxChartHeight,
                    ), // Tinggi minimal 5 agar terlihat jika ada data sedikit
                    decoration: BoxDecoration(
                      color: barColor.withAlpha(
                        204 + (0.2 * 255 * (height / maxChartHeight)).round(),
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    days[index],
                    style: TextStyle(
                      color: isToday
                          ? Colors.green.shade400
                          : Colors.grey.shade400,
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // Fungsi reset spesifik untuk Sesi Fokus (Reset Harian)
  void confirmResetFocusStats() {
    final timerController = context.read<timer_ctrl.TimerController>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Sesi Fokus Hari Ini?'),
        content: const Text(
          'Ini hanya akan mereset hitungan sesi fokus untuk hari ini menjadi nol.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              timerController.resetTodayFocusSessions();
              Navigator.pop(ctx);
            },
            child: Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void confirmResetTaskStatus() {
    final taskController = context.read<TaskController>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Status Tugas?'),
        content: const Text(
          'Ini akan mereset Status Tugas Selesai menjadi Tertunda (Berlaku untuk semua tugas).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              taskController.resetAllCompletedTasksStatus();
              Navigator.pop(ctx);
            },
            child: Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    final timerController = context.watch<timer_ctrl.TimerController>();
    _groupTasks(taskController);

    if (_selectedDay != null) {
      _selectedEvents.value = _getTasksForDay(_selectedDay!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistik & Kalender',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Calendar Widget
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: table_calendar.TableCalendar<Task>(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                headerStyle: table_calendar.HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: const Icon(
                    Icons.chevron_left,
                    color: AppColors.text,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right,
                    color: AppColors.text,
                  ),
                ),
                selectedDayPredicate: (day) =>
                    table_calendar.isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                eventLoader: _getTasksForDay,
                calendarBuilders: table_calendar.CalendarBuilders(
                  markerBuilder: (context, day, tasks) {
                    if (tasks.isNotEmpty) {
                      // Logic Marker
                      final now = DateTime.now();
                      Color markerColor;
                      bool hasOverdue = tasks.any(
                        (t) =>
                            !t.isCompleted &&
                            (t.deadline != null && t.deadline!.isBefore(now)),
                      );

                      if (hasOverdue) {
                        markerColor =
                            Colors.red; // Merah jika ada yang terlewat
                      } else if (tasks.every((t) => t.isCompleted)) {
                        markerColor = Colors.grey; // Abu-abu jika semua selesai
                      } else {
                        markerColor =
                            Colors.green.shade400; // Hijau jika aktif/pending
                      }

                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 6.0,
                          height: 6.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: markerColor,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),

            // 2. Daftar Tugas Pilihan (Posisi yang diminta)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deadline Tugas Dipilih (${_selectedDay != null ? DateFormat('d MMMM').format(_selectedDay!) : 'Pilih Tanggal'})',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.grey),
                  ValueListenableBuilder<List<Task>>(
                    valueListenable: _selectedEvents,
                    builder: (context, tasks, _) {
                      if (tasks.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 10.0,
                              bottom: 20,
                            ),
                            child: Text(
                              'Tidak ada deadline tugas untuk tanggal ini.',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                              onTap: () =>
                                  _showTaskDetailsDialog(context, task),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border(
                                    left: BorderSide(
                                      color: task.isCompleted
                                          ? Colors.green.shade400
                                          : AppColors.primary,
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    task.title,
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    task.deadline == null
                                        ? 'Sesi: ${task.pomodoroCount}'
                                        : 'Sesi: ${task.pomodoroCount} | Deadline: ${DateFormat('HH:mm').format(task.deadline!)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 13,
                                    ),
                                  ),
                                  trailing: Icon(
                                    task.isCompleted
                                        ? Icons.check_circle
                                        : Icons.arrow_forward_ios,
                                    color: task.isCompleted
                                        ? Colors.green.shade400
                                        : AppColors.text,
                                    size: task.isCompleted ? 24 : 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // 3. Konten Statistik (Diagram & Stat Cards)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Diagram Batang (Memanggil fungsi _buildWeeklyBarChart)
                  _buildWeeklyBarChart(context, timerController),

                  const SizedBox(height: 20),
                  const Text(
                    'Aktivitas Harian',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.grey),

                  StatCard(
                    title: 'Sesi Fokus Hari Ini',
                    value: timerController.todayFocusSessionsCompleted
                        .toString(),
                    icon: Icons.check_circle_outline,
                    onReset: confirmResetFocusStats,
                  ),

                  StatCard(
                    title: 'Tugas Selesai Hari Ini',
                    value: taskController.todayCompletedTasks.toString(),
                    icon: Icons.task_alt,
                    onReset: confirmResetTaskStatus,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
