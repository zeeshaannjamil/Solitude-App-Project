import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_wrapper.dart';
import '../../providers/theme_provider.dart';
import '../../config/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool breakReminders = true;
  bool weeklyReport = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Text("App Preferences", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ).animate().fade(duration: 400.ms),

            _buildSection(
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return _buildSwitchTile(
                      icon: Icons.dark_mode_rounded,
                      iconColor: Colors.deepPurple,
                      title: "Dark Mode",
                      subtitle: "Aesthetic dark theme",
                      value: themeProvider.isDark,
                      onChanged: (val) => themeProvider.toggleTheme(val),
                    );
                  },
                ),
              ],
            ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Text("Notifications", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ).animate().fade(delay: 200.ms),

            _buildSection(
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_active_rounded,
                  iconColor: const Color(0xFFF5A623),
                  title: "Push Notifications",
                  subtitle: "Focus reminders & daily quotes",
                  value: notifications,
                  onChanged: (val) => setState(() => notifications = val),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.coffee_rounded,
                  iconColor: const Color(0xFF8D6E63),
                  title: "Break Reminders",
                  subtitle: "Remind to rest your eyes",
                  value: breakReminders,
                  onChanged: (val) => setState(() => breakReminders = val),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.analytics_rounded,
                  iconColor: const Color(0xFF4A90E2),
                  title: "Weekly Report",
                  subtitle: "Screen time summary",
                  value: weeklyReport,
                  onChanged: (val) => setState(() => weeklyReport = val),
                ),
              ],
            ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Text("General", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ).animate().fade(delay: 400.ms),

            _buildSection(
              children: [
                _buildListTile(
                  icon: Icons.flag_rounded,
                  iconColor: const Color(0xFF50E3C2),
                  title: "Daily Goal",
                  subtitle: "Maximum 4 hours",
                  onTap: () {},
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.info_rounded,
                  iconColor: Colors.grey.shade600,
                  title: "About Solitude",
                  subtitle: "Version 1.0.0",
                  showArrow: false,
                  onTap: () {},
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.privacy_tip_rounded,
                  iconColor: const Color(0xFFE94A6A),
                  title: "Privacy Policy",
                  subtitle: "How we handle your data",
                  onTap: () {},
                ),
              ],
            ).animate().fade(delay: 500.ms).slideY(begin: 0.1),

            const SizedBox(height: 36),

            Center(
              child: TextButton.icon(
                onPressed: () async {
                  final logout = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );

                  if (logout != true) return;

                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthWrapper()),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.logout_rounded, color: Colors.red.shade400),
                label: Text("Log Out", style: TextStyle(color: Colors.red.shade400, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ).animate().fade(delay: 600.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Material wrapper ensures ink splashes are safely rendered
  Widget _buildSection({required List<Widget> children}) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 64, color: Colors.grey.withValues(alpha: 0.1));
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      trailing: showArrow ? Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400) : null,
    );
  }
}