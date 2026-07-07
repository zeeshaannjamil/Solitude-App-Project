import 'package:app_usage/app_usage.dart';
import 'package:usage_stats/usage_stats.dart';
import '../models/usage_models.dart';
import 'package:flutter/material.dart';

class DeviceUsageService {
  /// Check if usage permission is granted
  static Future<bool> checkPermission() async {
    bool? isGranted = await UsageStats.checkUsagePermission();
    return isGranted ?? false;
  }

  /// Request usage permission by opening settings
  static Future<void> requestPermission() async {
    await UsageStats.grantUsagePermission();
  }

  /// Fetches the Daily Usage
  static Future<DailyUsageModel> getDailyUsage() async {
    DateTime endDate = DateTime.now();
    DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day);

    return _getUsageModel(startDate, endDate);
  }

  /// Fetches the Weekly Usage
  static Future<DailyUsageModel> getWeeklyUsage() async {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 7));

    return _getUsageModel(startDate, endDate);
  }

  /// Fetches the Monthly Usage
  static Future<DailyUsageModel> getMonthlyUsage() async {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 30));

    return _getUsageModel(startDate, endDate);
  }

  static Future<DailyUsageModel> _getUsageModel(DateTime startDate, DateTime endDate) async {
    int unlockCount = 0;
    int totalMinutes = 0;
    List<AppUsageModel> apps = [];
    String? firstAppOpened;
    String? lastAppUsed;

    try {
      // 1. Get raw app usage from app_usage for clean app names and durations
      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startDate, endDate);
      infoList.sort((a, b) => b.usage.compareTo(a.usage));
      
      apps = infoList.where((info) => info.usage.inMinutes > 0).map((info) {
        return AppUsageModel(
          packageName: info.packageName,
          appName: info.appName,
          usageMinutes: info.usage.inMinutes,
        );
      }).toList();

      totalMinutes = apps.fold(0, (sum, app) => sum + app.usageMinutes);

      // 2. Get detailed events from usage_stats to calculate unlocks and sessions
      List<EventUsageInfo> events = await UsageStats.queryEvents(startDate, endDate);
      
      // Calculate unlocks (Event type 18 is usually KEYGUARD_HIDDEN or 15 is SCREEN_INTERACTIVE)
      // Some devices use 18 for unlock, some use 15 for screen on. We will count MOVE_TO_FOREGROUND (1)
      // as a proxy for sessions if unlock isn't strictly available, but usage_stats gives us 15, 16, 17, 18.
      int unlocks = 0;
      EventUsageInfo? firstEvent;
      EventUsageInfo? lastEvent;

      for (var event in events) {
        if (event.eventType == '15' || event.eventType == '18') {
          unlocks++;
        }
        if (event.eventType == '1') {
          firstEvent ??= event;
          lastEvent = event;
        }
      }
      unlockCount = unlocks;

      if (firstEvent != null) firstAppOpened = _getAppNameFromPackage(firstEvent.packageName, apps);
      if (lastEvent != null) lastAppUsed = _getAppNameFromPackage(lastEvent.packageName, apps);

    } catch (e) {
      debugPrint("Error fetching usage stats: $e");
    }

    return DailyUsageModel(
      totalScreenMinutes: totalMinutes,
      unlockCount: unlockCount,
      apps: apps,
      firstAppOpened: firstAppOpened,
      lastAppUsed: lastAppUsed,
    );
  }

  static String _getAppNameFromPackage(String? packageName, List<AppUsageModel> apps) {
    if (packageName == null) return "Unknown";
    try {
      return apps.firstWhere((app) => app.packageName == packageName).appName;
    } catch (e) {
      return packageName.split('.').last; // Fallback to last part of package
    }
  }
}
