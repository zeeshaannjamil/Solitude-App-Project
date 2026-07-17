import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../config/colors.dart';
import '../analytics/analytics_screen.dart';
import '../focus/focus_screen.dart';
import '../mirror/mirror_screen.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/screen_time_provider.dart';
import '../../widgets/dashboard_card.dart';
import '../journal/journal_screen.dart';
import '../../providers/journal_provider.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning 👋";
    if (hour < 17) return "Good Afternoon ☀️";
    if (hour < 21) return "Good Evening 🌙";
    return "Good Night 💤";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName?.isNotEmpty == true ? user!.displayName! : "Solitude User";
    final today = DateFormat("EEEE, dd MMMM yyyy").format(DateTime.now());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Solitude",
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 28, letterSpacing: 1.2),
        ).animate().fade(duration: 600.ms).slideX(begin: -0.2, end: 0),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ).animate().fade(duration: 600.ms).scale(),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const ProfileScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ).animate().fade(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
          ),
        ],
      ),
      body: Consumer3<DashboardProvider, ScreenTimeProvider, JournalProvider>(
        builder: (context, dashboard, screenTime, journalProvider, child) {
          
          final isScreenTimeLoading = screenTime.isLoading;
          final todayUsage = screenTime.todayUsage;
          final weeklyUsage = screenTime.weeklyUsage;
          
          final mostUsedApp = todayUsage?.apps.isNotEmpty == true ? todayUsage!.apps.first.appName : "None";
          final totalScreenMins = todayUsage?.totalScreenMinutes ?? 0;
          final unlockCount = todayUsage?.unlockCount ?? 0;
          final appsOpened = todayUsage?.apps.length ?? 0;
          final weeklyAvgMins = weeklyUsage != null ? (weeklyUsage.totalScreenMinutes ~/ 7) : 0;

          // Fake algorithm for wellbeing scores based on real screen time
          final digitalWellbeingScore = (100 - (totalScreenMins / 60) * 10).clamp(0, 100).toInt();
          final productivityScore = (dashboard.focusMinutes / 60 * 20).clamp(0, 100).toInt();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting(), style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600))
                    .animate().fade(duration: 500.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  userName,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 32),
                ).animate().fade(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 6),
                Text(today, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500))
                    .animate().fade(duration: 500.ms, delay: 300.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 32),

                // Primary Vital Signs
                _buildSectionHeader("Live Dashboard", theme).animate().fade(delay: 400.ms),
                const SizedBox(height: 16),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.05,
                  children: [
                    DashboardCard(
                      icon: Icons.phone_android_rounded,
                      title: "Screen Time",
                      value: isScreenTimeLoading ? "..." : screenTime.formatMinutes(totalScreenMins),
                      color: const Color(0xFF4A90E2),
                    ).animate().fade(delay: 500.ms).scale(),

                    DashboardCard(
                      icon: Icons.lock_open_rounded,
                      title: "Pickups",
                      value: isScreenTimeLoading ? "..." : "$unlockCount",
                      color: const Color(0xFFF5A623),
                    ).animate().fade(delay: 600.ms).scale(),

                    DashboardCard(
                      icon: Icons.timer_rounded,
                      title: "Focus Time",
                      value: "${dashboard.focusMinutes}m",
                      color: const Color(0xFFE94A6A),
                    ).animate().fade(delay: 700.ms).scale(),

                    DashboardCard(
                      icon: Icons.star_rounded,
                      title: "Most Used",
                      value: isScreenTimeLoading ? "..." : mostUsedApp,
                      color: const Color(0xFF50E3C2),
                    ).animate().fade(delay: 800.ms).scale(),
                  ],
                ),

                const SizedBox(height: 36),

                // Secondary Stats
                _buildSectionHeader("Digital Wellbeing", theme).animate().fade(delay: 900.ms),
                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.6,
                  children: [
                    _buildSmallStatCard(theme, "Wellbeing Score", "$digitalWellbeingScore%", Icons.health_and_safety_rounded, Colors.teal).animate().fade(delay: 1000.ms),
                    _buildSmallStatCard(theme, "Productivity", "$productivityScore%", Icons.trending_up_rounded, Colors.blue).animate().fade(delay: 1100.ms),
                    _buildSmallStatCard(theme, "Apps Opened", isScreenTimeLoading ? "..." : "$appsOpened", Icons.apps_rounded, Colors.purple).animate().fade(delay: 1200.ms),
                    _buildSmallStatCard(theme, "Weekly Avg", isScreenTimeLoading ? "..." : screenTime.formatMinutes(weeklyAvgMins), Icons.calendar_month_rounded, Colors.orange).animate().fade(delay: 1300.ms),
                  ],
                ),

                const SizedBox(height: 36),

                // Top 5 Apps List
                _buildSectionHeader("Top 5 Applications", theme).animate().fade(delay: 1400.ms),
                const SizedBox(height: 16),
                if (isScreenTimeLoading)
                  const Center(child: CircularProgressIndicator())
                else if (todayUsage == null || todayUsage.apps.isEmpty)
                  const Text("No usage data recorded today.", style: TextStyle(color: Colors.grey))
                else
                  ...todayUsage.apps.take(5).map((app) {
                    return _buildAppUsageTile(theme, app.appName, screenTime.formatMinutes(app.usageMinutes), totalScreenMins > 0 ? (app.usageMinutes / totalScreenMins) : 0)
                      .animate().fade(delay: 1500.ms).slideX(begin: 0.1);
                  }),

                const SizedBox(height: 36),

                // Quick Actions
                _buildSectionHeader("Quick Actions", theme).animate().fade(delay: 1600.ms),
                const SizedBox(height: 16),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: [
                    _buildQuickActionBtn(context, Icons.timer_outlined, "Focus", const FocusScreen()).animate().fade(delay: 1700.ms).scale(),
                    _buildQuickActionBtn(context, Icons.edit_note_rounded, "Journal", const JournalScreen()).animate().fade(delay: 1800.ms).scale(),
                    _buildQuickActionBtn(context, Icons.self_improvement_rounded, "Mirror", const MirrorScreen()).animate().fade(delay: 1900.ms).scale(),
                    _buildQuickActionBtn(context, Icons.insights_rounded, "Analytics", const AnalyticsScreen()).animate().fade(delay: 2000.ms).scale(),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
    );
  }

  Widget _buildSmallStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAppUsageTile(ThemeData theme, String appName, String timeStr, double percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.android_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            timeStr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn(BuildContext context, IconData icon, String title, Widget screen) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => screen,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                      .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                  child: child,
                );
              },
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}