class AppUsageModel {
  final String packageName;
  final String appName;
  final int usageMinutes;

  AppUsageModel({
    required this.packageName,
    required this.appName,
    required this.usageMinutes,
  });
}

class DailyUsageModel {
  final int totalScreenMinutes;
  final int unlockCount;
  final List<AppUsageModel> apps;
  final String? firstAppOpened;
  final String? lastAppUsed;

  DailyUsageModel({
    required this.totalScreenMinutes,
    required this.unlockCount,
    required this.apps,
    this.firstAppOpened,
    this.lastAppUsed,
  });
}
