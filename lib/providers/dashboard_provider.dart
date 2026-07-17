import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  // User
  String userName = "Mahad";

  // Dashboard Statistics
  int completedSessions = 0;
  int focusMinutes = 0;
  int streak = 8;
  int dailyGoal = 5;
  int mindfulnessScore = 82;

  // Temporary Screen Time
  int screenMinutes = 155;

  String breakMessage = "Take a short break and relax.";

  // Screen Time Text
  String get screenTime {
    final h = screenMinutes ~/ 60;
    final m = screenMinutes % 60;
    return "${h}h ${m}m";
  }

  // Progress
  double get progress {
    return (completedSessions / dailyGoal).clamp(0.0, 1.0);
  }

  // Goal Percentage
  String get goalPercentage {
    return "${(progress * 100).toInt()}%";
  }

  int get mindfulness => mindfulnessScore;

  void addSession(int minutes) {
    completedSessions++;
    focusMinutes += minutes;

    mindfulnessScore =
        (mindfulnessScore + 1).clamp(0, 100);

    notifyListeners();
  }

  void resetToday() {
    completedSessions = 0;
    focusMinutes = 0;
    notifyListeners();
  }

  void updateUser(String name) {
    userName = name;
    notifyListeners();
  }
}