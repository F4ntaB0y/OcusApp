import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:focus_app/core/theme/app_colors.dart';
import 'controller/task_controller.dart';
import '../tasks/model/task.dart';
import '../timer/controller/timer_controller.dart' as timer_ctrl;
import 'add_edit_task_page.dart';

// --- MOLECULE: Task Item Widget ---
class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onShowDetails;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPending = !task.isCompleted;

    final String deadlineText = task.deadline != null
        ? 'Deadline: ${DateFormat('d/MM HH:mm').format(task.deadline!)}'
        : 'Tidak ada deadline';

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: isPending
            ? Theme.of(context).cardColor
            : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CHECKBOX
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Checkbox(
              value: task.isCompleted,
              onChanged: (val) => onToggle(),
              activeColor: AppColors.primary,
              checkColor: AppColors.background,
            ),
          ),

          const SizedBox(width: 8.0),

          // 2. BODY TUGAS (Aksi: Tampilkan Detail)
          Expanded(
            child: InkWell(
              onTap: onShowDetails,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        color: isPending
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.description.isNotEmpty && isPending)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          task.description,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${task.pomodoroCount} Sesi | $deadlineText',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. TOMBOL HAPUS (Trailing)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red.shade400),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

// --- ORGANISM: TasksPage ---
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  void startFocusOnTask(BuildContext context, Task task) {
    final timerController = context.read<timer_ctrl.TimerController>();

    if (!timerController.isRunning) {
      timerController.startStopTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fokus dimulai untuk: ${task.title}'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Timer sudah berjalan. Jeda atau selesaikan sesi saat ini.',
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
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

  void navigateToAddTask(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => const AddEditTaskPage()));
  }

  // Widget untuk tampilan kosong di tengah layar
  Widget _buildEmptyTasksView() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: Center(
            child: Text(
              'Tidak ada tugas saat ini. Tambahkan tugas baru!',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Tugas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Consumer<TaskController>(
        builder: (context, controller, child) {
          final pendingTasks = controller.pendingTasks;
          final completedTasks = controller.tasks
              .where((t) => t.isCompleted)
              .toList();
          final bool isListEmpty =
              pendingTasks.isEmpty && completedTasks.isEmpty;

          if (isListEmpty) {
            return _buildEmptyTasksView();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              // --- 1. Tugas yang Belum Selesai (Fokus Anda) ---
              const Text(
                'Fokus Anda',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.grey),
              ...pendingTasks.map(
                (task) => TaskItem(
                  task: task,
                  onToggle: () => controller.toggleTaskCompletion(task.id),
                  onDelete: () => controller.deleteTask(task.id),
                  onShowDetails: () => _showTaskDetailsDialog(context, task),
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. Tugas yang Sudah Selesai ---
              if (completedTasks.isNotEmpty) ...[
                const Text(
                  'Selesai',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.grey),
                ...completedTasks.map(
                  (task) => TaskItem(
                    task: task,
                    onToggle: () => controller.toggleTaskCompletion(task.id),
                    onDelete: () => controller.deleteTask(task.id),
                    onShowDetails: () => _showTaskDetailsDialog(context, task),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToAddTask(context),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: AppColors.background),
      ),
    );
  }
}
