import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/colors.dart';
import '../../providers/focus_provider.dart';
import '../../providers/screen_time_provider.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final focus = Provider.of<FocusProvider>(context);
    final screenTime = Provider.of<ScreenTimeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Focus Mode",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              Text(
                "Stay Focused",
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 32),
              ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 8),

              Text(
                "One session at a time.",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500),
              ).animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 40),

              // Timer Circle
              SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: CircularProgressIndicator(
                        value: focus.progress,
                        strokeWidth: 14,
                        strokeCap: StrokeCap.round,
                        backgroundColor: theme.cardColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ).animate(target: focus.isRunning ? 1 : 0)
                     .scaleXY(begin: 1.0, end: 1.02, duration: 1.seconds, curve: Curves.easeInOutSine),

                    Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: focus.isRunning ? 0.15 : 0.05),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.self_improvement_rounded,
                            size: 40,
                            color: focus.isRunning ? AppColors.primary : Colors.grey.shade400,
                          ).animate(target: focus.isRunning ? 1 : 0)
                           .tint(color: AppColors.primary, duration: 500.ms)
                           .shake(hz: 2, curve: Curves.easeInOutSine),

                          const SizedBox(height: 12),

                          Text(
                            focus.time,
                            style: const TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.5,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            focus.isRunning ? "Focus Session Running" : "Ready to Start",
                            style: TextStyle(
                              color: focus.isRunning ? AppColors.primary : Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),

              const SizedBox(height: 50),

              // Controls
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: focus.start,
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: const Text("Start", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF50E3C2),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                    ).animate().fade(delay: 300.ms).slideX(begin: -0.1),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: focus.pause,
                      icon: const Icon(Icons.pause_rounded, size: 28),
                      label: const Text("Pause", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5A623),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                    ).animate().fade(delay: 300.ms).slideX(begin: 0.1),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: focus.reset,
                  icon: const Icon(Icons.refresh_rounded, size: 24),
                  label: const Text("Reset Session", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.cardColor,
                    foregroundColor: const Color(0xFFE94A6A),
                    minimumSize: const Size(0, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      icon: Icons.lock_open_rounded,
                      color: const Color(0xFFF5A623),
                      title: "Today's Unlocks",
                      value: screenTime.isLoading ? "..." : "${screenTime.todayUsage?.unlockCount ?? 0}",
                    ).animate().fade(delay: 500.ms).scale(begin: const Offset(0.9, 0.9)),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _buildInfoCard(
                      context,
                      icon: Icons.timer_rounded,
                      color: AppColors.primary,
                      title: "Goal",
                      value: "25 Min",
                    ).animate().fade(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required Color color, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
