import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import 'controller/timer_controller.dart';
import 'focus_mode_page.dart';
import 'settings_page.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  // Fungsi untuk mendapatkan warna berdasarkan mode
  Color _getModeColor(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return AppColors.primary; // Hijau (Fokus)
      case TimerMode.shortBreak:
        return Colors.lightBlue; // Biru Muda (Istirahat Pendek)
      case TimerMode.longBreak:
        return Colors.orange; // Oranye (Istirahat Panjang)
    }
  }

  // Fungsi navigasi ke Setting Page
  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerController>(
      builder: (context, controller, child) {
        final modeColor = _getModeColor(controller.currentMode);

        // Menentukan total durasi berdasarkan mode saat ini (dalam detik)
        int totalDurationSeconds = controller.currentMode == TimerMode.focus
            ? controller.focusDuration
            : controller.currentMode == TimerMode.shortBreak
            ? controller.shortBreakDuration
            : controller.longBreakDuration;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Pengelola Sesi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            centerTitle: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            actions: [
              // Tombol Setting di AppBar
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.grey),
                onPressed: () => _openSettings(context),
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Judul dan Deskripsi Dinamis
                Text(
                  controller.modeTitle,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  controller.modeDescription,
                  style: TextStyle(
                    color: modeColor.withAlpha(204),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 50),

                // Lingkaran Timer
                GestureDetector(
                  onTap: () {
                    if (controller.currentMode == TimerMode.focus &&
                        controller.isRunning) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FocusModePage(),
                        ),
                      );
                    } else {
                      controller.startStopTimer();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress Bar
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CircularProgressIndicator(
                          value:
                              1.0 -
                              (controller.currentSeconds /
                                  totalDurationSeconds),
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation<Color>(modeColor),
                        ),
                      ),
                      // Teks Waktu
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.formattedTime,
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.w100,
                              color: modeColor,
                            ),
                          ),
                          const Text(
                            'Minutes Left',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // Tombol Aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tombol Reset
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        size: 30,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: controller.resetTimer,
                    ),
                    const SizedBox(width: 20),

                    // Tombol Play/Pause
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: modeColor,
                        boxShadow: [
                          BoxShadow(
                            color: modeColor.withAlpha(128),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          controller.isRunning ? Icons.pause : Icons.play_arrow,
                          size: 50,
                          color: AppColors.background,
                        ),
                        onPressed: controller.startStopTimer,
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Tombol Skip (Lewatkan mode saat ini)
                    IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        size: 30,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: controller.skipMode,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // PETUNJUK BARU (Tanpa Italic)
                if (!controller.isRunning)
                  Text(
                    'Tekan tombol ${controller.currentMode == TimerMode.focus ? 'PLAY' : 'STOP'} untuk memulai ${controller.modeTitle}.',
                    style: TextStyle(
                      color: modeColor.withAlpha(204),
                      fontSize: 16,
                    ), // Hapus fontStyle: FontStyle.italic
                  )
                else
                  Text(
                    'Fokus Cycle: ${controller.focusCycleCount} / ${TimerController.focusCyclesBeforeLongBreak}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
