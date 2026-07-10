import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../config/colors.dart';
import '../auth/auth_wrapper.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/screen_time_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _logout(BuildContext context) async {
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
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    
    final dashboard = Provider.of<DashboardProvider>(context);
    final screenTime = Provider.of<ScreenTimeProvider>(context);

    final totalScreenTime = screenTime.weeklyUsage?.totalScreenMinutes ?? 0;
    final creationDate = user?.metadata.creationTime;
    final memberSince = creationDate != null ? "${creationDate.month}/${creationDate.year}" : "Unknown";

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          Hero(
            tag: "profile_screen_avatar",
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
          ).animate().fade().scale(),
          const SizedBox(height: 20),
          Text(
            user?.displayName?.isNotEmpty == true
                ? user!.displayName!
                : "Solitude User",
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? "No email",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),

          // Live Statistics
          const Text("Live Statistics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month_rounded, color: Colors.purple),
              title: const Text("Member Since"),
              trailing: Text(memberSince, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ).animate().fade(delay: 100.ms),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_android_rounded, color: Colors.blue),
              title: const Text("Weekly Screen Time"),
              trailing: Text(screenTime.formatMinutes(totalScreenTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ).animate().fade(delay: 200.ms),
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer_rounded, color: Colors.redAccent),
              title: const Text("Total Focus Hours"),
              trailing: Text("${dashboard.focusMinutes ~/ 60}h", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ).animate().fade(delay: 300.ms),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_fire_department, color: Colors.orange),
              title: const Text("Current Streak"),
              trailing: Text("${dashboard.streak} Days", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ).animate().fade(delay: 400.ms),

          const SizedBox(height: 30),
          SizedBox(
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
                if (result == true) {
                  setState(() {}); // Rebuild to fetch updated display name
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit Profile"),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 55,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out"),
            ),
          ),
        ],
      ),
    );
  }
}
