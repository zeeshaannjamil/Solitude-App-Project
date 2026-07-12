import 'dart:async';
import 'package:flutter/material.dart';
import '../models/usage_models.dart';
import '../services/device_usage_service.dart';

class ScreenTimeProvider extends ChangeNotifier {
  bool _hasPermission = false;
  bool _isLoading = true;
  String? _errorMessage;

  DailyUsageModel? _todayUsage;
  DailyUsageModel? _weeklyUsage;
  DailyUsageModel? _monthlyUsage;

  Timer? _refreshTimer;

  bool get hasPermission => _hasPermission;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DailyUsageModel? get todayUsage => _todayUsage;
  DailyUsageModel? get weeklyUsage => _weeklyUsage;
  DailyUsageModel? get monthlyUsage => _monthlyUsage;

  ScreenTimeProvider() {
    _init();
    // Auto refresh every 5 minutes while the app is running
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_hasPermission) refreshData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    await checkPermission();
  }

  Future<void> checkPermission() async {
    _isLoading = true;
    notifyListeners();

    try {
      _hasPermission = await DeviceUsageService.checkPermission();
      if (_hasPermission) {
        await refreshData();
      }
    } catch (e) {
      _errorMessage = "Failed to check permission: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> requestPermission() async {
    await DeviceUsageService.requestPermission();
    await checkPermission();
  }

  Future<void> refreshData() async {
    if (!_hasPermission) return;

    try {
      _todayUsage = await DeviceUsageService.getDailyUsage();
      _weeklyUsage = await DeviceUsageService.getWeeklyUsage();
      // Optional: Fetch monthly if needed
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Failed to load usage data: $e";
    }

    notifyListeners();
  }

  String formatMinutes(int? totalMinutes) {
    if (totalMinutes == null) return "0m";
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h == 0) return "${m}m";
    return "${h}h ${m}m";
  }
}
