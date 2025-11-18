import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:focus_app/core/theme/app_colors.dart';
import '../tasks/controller/task_controller.dart';
import '../tasks/model/task.dart';
import '../tasks/add_edit_task_page.dart'; // Import untuk tombol Edit

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  List<Task> _selectedTasks = [];
  late final ValueNotifier<List<Task>> _selectedEvents;

  // PERBAIKAN: Mengubah deklarasi menjadi final
  final Map<DateTime, List<Task>> _tasksByDay = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    // Panggil _groupTasks untuk menginisialisasi _tasksByDay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupTasks(context.read<TaskController>());
      _selectedEvents.value = _getTasksForDay(_selectedDay!);
    });
    _selectedEvents = ValueNotifier([]);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  // Normalisasi tanggal untuk akurasi pemetaan (ke tengah malam UTC)
  DateTime _normalizeDate(DateTime day) {
    return DateTime.utc(day.year, day.month, day.day);
  }

  // Fungsi untuk memetakan tugas yang BELUM SELESAI ke tanggal deadline mereka
  void _groupTasks(TaskController controller) {
    _tasksByDay.clear();
    for (var task in controller.pendingTasks) {
      if (task.deadline != null) {
        final normalizedDay = _normalizeDate(task.deadline!);

        if (_tasksByDay[normalizedDay] == null) {
          _tasksByDay[normalizedDay] = [];
        }
        _tasksByDay[normalizedDay]!.add(task);
      }
    }
  }

  // EventLoader: Mengambil tugas untuk hari tertentu
  List<Task> _getTasksForDay(DateTime day) {
    return _tasksByDay[_normalizeDate(day)] ?? [];
  }

  // Handler saat hari di kalender dipilih
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedTasks = _getTasksForDay(selectedDay);
        _selectedEvents.value = _selectedTasks;
      });
    }
  }

  // Dialog untuk menampilkan detail tugas
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
            // Tombol EDIT (Memindahkan ke halaman edit)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Tutup dialog
                // Navigasi ke halaman edit menggunakan context utama
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

  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    // PENTING: Panggil _groupTasks di sini untuk trigger saat ada perubahan data
    _groupTasks(taskController);

    // Pastikan daftar tugas terbarui setiap kali data berubah
    if (_selectedDay != null) {
      _selectedTasks = _getTasksForDay(_selectedDay!);
      _selectedEvents.value = _selectedTasks;
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
      body: Column(
        children: [
          // 1. Calendar Widget
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: TableCalendar<Task>(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              eventLoader: _getTasksForDay,

              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: AppColors.text,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: AppColors.text,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: AppColors.text,
                ),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(color: AppColors.text),
                weekendTextStyle: TextStyle(color: Colors.grey.shade600),
                todayDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                markerSize: 5.0,
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: AppColors.primary),
                weekendStyle: TextStyle(color: Colors.red.shade400),
              ),

              // Custom builder untuk penanda event (marker)
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, tasks) {
                  if (tasks.isNotEmpty) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          shape: BoxShape.circle,
                        ),
                        width: 6.0,
                        height: 6.0,
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),

          // 2. Daftar Tugas (Dapat Ditekan)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tugas Deadline ${DateFormat('EEEE, d MMMM yyyy').format(_selectedDay!)}',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.grey),
                  Expanded(
                    child: ValueListenableBuilder<List<Task>>(
                      valueListenable: _selectedEvents,
                      builder: (context, tasks, _) {
                        if (tasks.isEmpty) {
                          return Center(
                            child: Text(
                              'Tidak ada deadline tugas untuk tanggal ini.',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];

                            return InkWell(
                              onTap: () => _showTaskDetailsDialog(
                                context,
                                task,
                              ), // FUNGSI KLIK
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                margin: const EdgeInsets.only(bottom: 8.0),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border(
                                    left: BorderSide(
                                      color: AppColors.primary,
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
                                    '${task.pomodoroCount} Sesi | ${DateFormat('HH:mm').format(task.deadline!)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
