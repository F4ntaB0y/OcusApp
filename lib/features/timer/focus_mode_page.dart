import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import 'controller/timer_controller.dart';

class FocusModePage extends StatelessWidget {
  const FocusModePage({super.key});

  // FUNGSI PERBAIKAN: Hanya pop, TIDAK memanggil controller.startStopTimer()
  void _exitFocusMode(BuildContext context, TimerController controller) {
    // Timer dibiarkan berjalan di latar belakang
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<TimerController>();

    return Selector<TimerController, String>(
      selector: (context, c) => c.formattedTime,
      builder: (context, currentTime, child) {
        final isRunning = context.select<TimerController, bool>(
          (c) => c.isRunning,
        );

        // Logika untuk kembali otomatis jika timer habis (tetap dipertahankan)
        if (!isRunning && currentTime == controller.formattedTime) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            }
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,

          appBar: AppBar(
            backgroundColor: AppColors.background.withAlpha(200),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey),
              onPressed: () => _exitFocusMode(context, controller), // Hanya pop
            ),
            title: const Text(
              'Fokus Mode',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),

          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Tampilan Waktu Besar
                Text(
                  currentTime,
                  style: const TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.w100,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 50),

                // Tombol Stop (Tombol ini tetap menjeda timer)
                _buildStopButton(context, controller),
                const SizedBox(height: 10),
                const Text(
                  'Tombol STOP akan menjeda timer dan keluar',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStopButton(BuildContext context, TimerController controller) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red.shade700,
        boxShadow: [
          BoxShadow(color: Colors.red.withAlpha(128), blurRadius: 15),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.stop, size: 50, color: AppColors.text),
        onPressed: () {
          // Tombol STOP: Menjeda timer dan keluar
          controller.startStopTimer();
          Navigator.pop(context);
        },
      ),
    );
  }
}
