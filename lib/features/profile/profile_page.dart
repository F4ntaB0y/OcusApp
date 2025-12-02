import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus_app/core/theme/app_colors.dart';
import 'controller/profile_controller.dart';
import '../tasks/controller/task_controller.dart';
import '../timer/controller/timer_controller.dart';

// --- WIDGET: Stat Card ---
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade900,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
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
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // 1. Dialog Edit Profil (Nama & Bio)
  void _showEditProfileDialog(
    BuildContext context,
    ProfileController controller,
  ) {
    final nameController = TextEditingController(text: controller.username);
    final bioController = TextEditingController(text: controller.bio);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pengguna',
                  hintText: 'Masukkan nama baru',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi / Bio',
                  hintText: 'Tulis sesuatu tentang dirimu',
                ),
                maxLines: 3,
                minLines: 1,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              controller.updateUsername(nameController.text);
              controller.updateBio(bioController.text);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Simpan',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog Pilih Avatar
  void _showAvatarSelectionDialog(
    BuildContext context,
    ProfileController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Pilih Avatar'),
        children: [
          _buildAvatarOption(ctx, controller, 0, 'Default', Icons.person),
          _buildAvatarOption(ctx, controller, 1, 'Pria', Icons.face),
          _buildAvatarOption(ctx, controller, 2, 'Wanita', Icons.face_3),
        ],
      ),
    );
  }

  Widget _buildAvatarOption(
    BuildContext context,
    ProfileController controller,
    int index,
    String label,
    IconData icon,
  ) {
    return SimpleDialogOption(
      onPressed: () {
        controller.updateAvatar(index);
        Navigator.pop(context);
      },
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: controller.avatarIndex == index
                ? AppColors.primary
                : Colors.grey.shade800,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontWeight: controller.avatarIndex == index
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: controller.avatarIndex == index ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi Reset Global
  void _confirmGlobalReset(BuildContext context) {
    final timerController = context.read<TimerController>();
    final taskController = context.read<TaskController>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Statistik Global?'),
        content: const Text(
          'Ini akan mereset Total Sesi Fokus Keseluruhan dan status semua Tugas Selesai.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              taskController.resetAllCompletedTasksStatus();
              timerController.resetTotalFocusSessions();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data berhasil direset.')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getAvatarIcon(int index) {
    switch (index) {
      case 1:
        return Icons.face;
      case 2:
        return Icons.face_3;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final timerController = context.watch<TimerController>();
    final taskController = context.watch<TaskController>();

    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // --- 1. BAGIAN PROFIL ---
            Center(
              child: Column(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () =>
                        _showAvatarSelectionDialog(context, profileController),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade800,
                          child: Icon(
                            _getAvatarIcon(profileController.avatarIndex),
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CONTAINER INFORMASI (Nama & Bio)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade800,
                        width: 0.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Konten Teks (Tengah)
                        Column(
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              profileController.username,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Divider(
                              color: Colors.grey,
                              height: 1,
                              thickness: 0.2,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              profileController.bio,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        // Tombol Edit (Pojok Kanan Atas Box)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => _showEditProfileDialog(
                              context,
                              profileController,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- 2. STATISTIK GLOBAL ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Statistik Global',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _confirmGlobalReset(context),
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 20,
                  ),
                  label: const Text(
                    "Reset Data",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.grey),

            StatCard(
              title: 'Total Sesi Fokus',
              value: timerController.focusSessionsCompletedTotal.toString(),
              icon: Icons.access_time_filled,
            ),
            StatCard(
              title: 'Total Tugas Selesai',
              value: taskController.totalTasksCompleted.toString(),
              icon: Icons.check_circle_outline,
            ),

            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Tepat Waktu',
                    value: taskController.totalTasksOnTime.toString(),
                    icon: Icons.thumb_up_alt,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    title: 'Terlambat',
                    value: taskController.totalTasksLate.toString(),
                    icon: Icons.warning_amber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- 3. PENGATURAN ---
            const Text(
              'Pengaturan',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.grey),

            Card(
              color: cardColor,
              child: SwitchListTile(
                title: const Text(
                  'Notifikasi Suara',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Bunyi saat timer selesai'),
                secondary: const Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.primary,
                ),
                value: profileController.enableNotifications,
                activeColor: AppColors.primary,
                onChanged: (bool value) {
                  profileController.toggleNotifications(value);
                },
              ),
            ),

            Card(
              color: cardColor,
              child: ListTile(
                leading: const Icon(Icons.color_lens, color: AppColors.primary),
                title: const Text(
                  'Tema Aplikasi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Tema Gelap (Default)'),
                trailing: const Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Fitur ganti tema sedang dalam pengembangan.',
                      ),
                    ),
                  );
                },
              ),
            ),

            Card(
              color: cardColor,
              child: ListTile(
                leading: const Icon(Icons.language, color: AppColors.primary),
                title: const Text(
                  'Bahasa',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Indonesia (Default)'),
                trailing: const Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur Bahasa belum tersedia.'),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // 4. Info App
            Center(
              child: Text(
                'Ocus v1.0.0',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
