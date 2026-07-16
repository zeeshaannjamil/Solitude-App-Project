import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/colors.dart';
import '../journal/journal_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/screen_time_provider.dart';

class MirrorScreen extends StatelessWidget {
  const MirrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenTime = Provider.of<ScreenTimeProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Minimalist Mirror", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.self_improvement_rounded,
                size: 80,
                color: AppColors.primary,
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.05, duration: 2.seconds),
            ).animate().fade(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: 32),

            Text(
              "Take a Moment",
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 12),

            Text(
              "Your phone should serve your goals,\nnot steal your attention.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

            const SizedBox(height: 40),

            _buildStatCard(
                    context, 
                    Icons.phone_android_rounded, 
                    AppColors.primary, 
                    "Today's Screen Time", 
                    screenTime.isLoading ? "..." : screenTime.formatMinutes(screenTime.todayUsage?.totalScreenMinutes))
                .animate().fade(delay: 400.ms).slideX(begin: -0.1),
            _buildStatCard(context, Icons.favorite_rounded, const Color(0xFFE94A6A), "Mood", "😊 Calm")
                .animate().fade(delay: 500.ms).slideX(begin: -0.1),
            _buildStatCard(context, Icons.emoji_events_rounded, const Color(0xFFF5A623), "Mindfulness Score", "82%")
                .animate().fade(delay: 600.ms).slideX(begin: -0.1),

            const SizedBox(height: 40),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Today's Reflection",
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ).animate().fade(delay: 700.ms),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.format_quote_rounded, size: 40, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text(
                    "Did your phone usage today help you achieve your goals, or did it distract you?\n\nTake one minute to think before opening another app.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fade(delay: 800.ms).scale(begin: const Offset(0.95, 0.95)),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JournalScreen()),
                  );
                },
                icon: const Icon(Icons.edit_note_rounded, size: 28),
                label: const Text("Write Journal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
              ),
            ).animate().fade(delay: 900.ms).slideY(begin: 0.1),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, Color color, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color == AppColors.primary ? color : Colors.black87,
          ),
        ),
      ),
    );
  }
}