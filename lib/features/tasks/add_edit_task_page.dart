import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:focus_app/core/theme/app_colors.dart';
import 'package:focus_app/features/tasks/controller/task_controller.dart';
import 'package:focus_app/features/tasks/model/task.dart';

class AddEditTaskPage extends StatefulWidget {
  final Task? taskToEdit;

  const AddEditTaskPage({super.key, this.taskToEdit});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime? _selectedDeadline;
  late int _pomodoroCount; // Field ini sekarang digunakan

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;

    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _selectedDeadline = task?.deadline;
    _pomodoroCount = task?.pomodoroCount ?? 1;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih tanggal dan waktu
  Future<void> _pickDateTime(BuildContext context) async {
    final BuildContext dialogContext = context;

    final DateTime? pickedDate = await showDatePicker(
      context: dialogContext,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onSurface: AppColors.text,
              surface: AppColors.background,
              onPrimary: AppColors.background,
            ),
            dialogTheme: DialogTheme.of(
              context,
            ).copyWith(backgroundColor: AppColors.background),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && dialogContext.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: dialogContext,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDeadline ?? DateTime.now(),
        ),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppColors.primary,
                onSurface: AppColors.text,
                surface: AppColors.background,
                onPrimary: AppColors.background,
              ),
              dialogTheme: DialogTheme.of(
                context,
              ).copyWith(backgroundColor: AppColors.background),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // Fungsi untuk menyimpan atau memperbarui tugas
  void _saveTask(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = context.read<TaskController>();
    final title = _titleController.text;
    final description = _descriptionController.text;

    if (widget.taskToEdit == null) {
      // Tambah Tugas Baru
      controller.addTask(
        title,
        description: description,
        deadline: _selectedDeadline,
        pomodoroCount: _pomodoroCount, // DIGUNAKAN DI SINI
      );
    } else {
      // Edit Tugas Lama
      controller.updateTask(
        id: widget.taskToEdit!.id,
        title: title,
        description: description,
        deadline: _selectedDeadline,
        pomodoroCount: _pomodoroCount, // DIGUNAKAN DI SINI
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Tugas' : 'Tambah Tugas Baru'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Judul Tugas
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Tugas',
                  labelStyle: TextStyle(color: AppColors.primary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                style: const TextStyle(color: AppColors.text),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Deskripsi
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  labelStyle: TextStyle(color: AppColors.primary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                style: const TextStyle(color: AppColors.text),
              ),
              const SizedBox(height: 30),

              // Deadline Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Deadline:',
                    style: TextStyle(color: AppColors.primary, fontSize: 16),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.calendar_today, color: AppColors.text),
                    label: Text(
                      _selectedDeadline == null
                          ? 'Atur Tanggal & Waktu'
                          : DateFormat(
                              'dd MMM, HH:mm',
                            ).format(_selectedDeadline!),
                      style: const TextStyle(color: AppColors.text),
                    ),
                    onPressed: () => _pickDateTime(context),
                  ),
                ],
              ),
              if (_selectedDeadline != null)
                TextButton.icon(
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text(
                    'Hapus Deadline',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedDeadline = null;
                    });
                  },
                ),
              const SizedBox(height: 30),

              // Pomodoro Count Control
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sesi Pomodoro Dibutuhkan:',
                    style: TextStyle(color: AppColors.primary, fontSize: 16),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: AppColors.text),
                        onPressed: () {
                          if (_pomodoroCount > 1) {
                            setState(() {
                              _pomodoroCount--;
                            });
                          }
                        },
                      ),
                      Text(
                        '$_pomodoroCount',
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.text),
                        onPressed: () {
                          setState(() {
                            _pomodoroCount++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveTask(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    isEditing ? 'Simpan Perubahan' : 'Tambah Tugas',
                    style: TextStyle(fontSize: 18, color: AppColors.background),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
