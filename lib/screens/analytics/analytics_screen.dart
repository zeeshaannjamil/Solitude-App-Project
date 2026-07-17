import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../config/colors.dart';
import '../../../providers/screen_time_provider.dart';
import '../../../providers/dashboard_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenTime = Provider.of<ScreenTimeProvider>(context);
    final dashboard = Provider.of<DashboardProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Analytics", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: !screenTime.hasPermission && !screenTime.isLoading
          ? Center(child: _buildPermissionCard(context, screenTime))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Usage Overview
                  Text("Usage Overview", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
                      .animate().fade(delay: 100.ms),
                  const SizedBox(height: 16),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text("Daily Average", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        screenTime.isLoading 
                            ? const CircularProgressIndicator()
                            : Text(
                                screenTime.formatMinutes(screenTime.todayUsage?.totalScreenMinutes),
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1),
                              ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMiniStat("Weekly", screenTime.isLoading ? "..." : screenTime.formatMinutes(screenTime.weeklyUsage?.totalScreenMinutes ?? 0)),
                            Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.2)),
                            _buildMiniStat("Monthly", screenTime.isLoading ? "..." : screenTime.formatMinutes(screenTime.monthlyUsage?.totalScreenMinutes ?? 0)),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

                  const SizedBox(height: 36),

                  // Trend Analysis (Chart)
                  Text("Usage Trends", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
                      .animate().fade(delay: 300.ms),
                  const SizedBox(height: 16),

                  Container(
                    height: 250,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                    ),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 10,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const titles = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    titles[value.toInt()],
                                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          _makeBarData(0, 4),
                          _makeBarData(1, 6),
                          _makeBarData(2, 5),
                          _makeBarData(3, 8),
                          _makeBarData(4, 3),
                          _makeBarData(5, 7),
                          _makeBarData(6, 4.5),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: 400.ms).scaleXY(begin: 0.95),

                  const SizedBox(height: 36),

                  // Deep Analytics Grid
                  Text("Deep Analytics", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
                      .animate().fade(delay: 500.ms),
                  const SizedBox(height: 16),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _buildGridStatCard(theme, Icons.timeline_rounded, "Focus Ratio", "${dashboard.mindfulnessScore}%", Colors.indigo).animate().fade(delay: 550.ms),
                      _buildGridStatCard(theme, Icons.warning_rounded, "Distractions", "${screenTime.todayUsage?.unlockCount ?? 0} Pickups", Colors.deepOrange).animate().fade(delay: 600.ms),
                      _buildGridStatCard(theme, Icons.check_circle_rounded, "Productivity", "${dashboard.completedSessions} Sessions", Colors.teal).animate().fade(delay: 650.ms),
                      _buildGridStatCard(theme, Icons.trending_down_rounded, "Avg. Drop", "12%", Colors.green).animate().fade(delay: 700.ms),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // App Rankings
                  Text("Top Applications", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
                      .animate().fade(delay: 800.ms),
                  const SizedBox(height: 16),

                  if (screenTime.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (screenTime.todayUsage == null || screenTime.todayUsage!.apps.isEmpty)
                    const Center(child: Text("No app usage data available.", style: TextStyle(color: Colors.grey)))
                  else
                    ...screenTime.todayUsage!.apps.take(8).map((info) {
                      return buildTile(context, Icons.android_rounded, info.appName, screenTime.formatMinutes(info.usageMinutes), AppColors.primary).animate().fade(delay: 900.ms).slideY(begin: 0.1);
                    }),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildGridStatCard(ThemeData theme, IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(BuildContext context, ScreenTimeProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_person_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.8)),
            const SizedBox(height: 16),
            const Text("Usage Access Required", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              "To provide real-time device statistics, Solitude needs permission to access your device usage history.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => provider.requestPermission(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Grant Permission", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 16,
          borderRadius: BorderRadius.circular(8),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: Colors.grey.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget buildTile(BuildContext context, IconData icon, String title, String value, Color color) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}