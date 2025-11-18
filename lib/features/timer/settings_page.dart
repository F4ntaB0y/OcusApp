// lib/features/timer/settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focus_app/core/theme/app_colors.dart';
import 'controller/timer_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerController>(
      builder: (context, controller, child) {
        int focusMinutes = controller.focusDuration ~/ 60;
        int shortBreakMinutes = controller.shortBreakDuration ~/ 60;
        int longBreakMinutes = controller.longBreakDuration ~/ 60;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Pengaturan Pomodoro',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.background,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              // Durasi Fokus
              _buildDurationControl(
                context,
                title: 'Durasi Fokus (Menit)',
                initialValue: focusMinutes,
                onChanged: (newValue) {
                  focusMinutes = newValue;
                  controller.setDurations(
                    // Panggilan sudah benar
                    focusMinutes: focusMinutes,
                    shortBreakMinutes: shortBreakMinutes,
                    longBreakMinutes: longBreakMinutes,
                  );
                },
                isTimerRunning: controller.isRunning,
              ),
              const Divider(color: Colors.grey),

              // Durasi Istirahat Pendek
              _buildDurationControl(
                context,
                title: 'Durasi Istirahat Pendek (Menit)',
                initialValue: shortBreakMinutes,
                onChanged: (newValue) {
                  shortBreakMinutes = newValue;
                  controller.setDurations(
                    // Panggilan sudah benar
                    focusMinutes: focusMinutes,
                    shortBreakMinutes: shortBreakMinutes,
                    longBreakMinutes: longBreakMinutes,
                  );
                },
                isTimerRunning: controller.isRunning,
              ),
              const Divider(color: Colors.grey),

              // Durasi Istirahat Panjang
              _buildDurationControl(
                context,
                title: 'Durasi Istirahat Panjang (Menit)',
                initialValue: longBreakMinutes,
                onChanged: (newValue) {
                  longBreakMinutes = newValue;
                  controller.setDurations(
                    // Panggilan sudah benar
                    focusMinutes: focusMinutes,
                    shortBreakMinutes: shortBreakMinutes,
                    longBreakMinutes: longBreakMinutes,
                  );
                },
                isTimerRunning: controller.isRunning,
              ),
              const SizedBox(height: 20),

              if (controller.isRunning)
                const Text(
                  'Timer sedang berjalan. Pengaturan dikunci.',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                const Text(
                  'Pengaturan hanya dapat diubah saat timer berhenti.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDurationControl(
    BuildContext context, {
    required String title,
    required int initialValue,
    required ValueChanged<int> onChanged,
    required bool isTimerRunning,
  }) {
    // ... (Logika _buildDurationControl) ...
    return StatefulBuilder(
      builder: (context, setState) {
        int currentValue = initialValue;
        bool isDisabled = isTimerRunning;

        void increment() {
          if (!isDisabled) {
            setState(() {
              currentValue++;
              onChanged(currentValue);
            });
          }
        }

        void decrement() {
          if (!isDisabled && currentValue > 1) {
            // Minimal 1 menit
            setState(() {
              currentValue--;
              onChanged(currentValue);
            });
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDisabled ? Colors.grey : AppColors.text,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: isDisabled
                          ? Colors.grey.shade700
                          : AppColors.primary,
                    ),
                    onPressed: decrement,
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$currentValue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDisabled ? Colors.grey : AppColors.text,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: isDisabled
                          ? Colors.grey.shade700
                          : AppColors.primary,
                    ),
                    onPressed: increment,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
