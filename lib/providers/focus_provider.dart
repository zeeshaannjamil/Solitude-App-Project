import 'dart:async';
import 'package:flutter/material.dart';

class FocusProvider extends ChangeNotifier {
  static const int totalSeconds = 25 * 60;

  int seconds = totalSeconds;

  Timer? _timer;

  bool isRunning = false;

  String get time {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  double get progress => seconds / totalSeconds;

  void start() {
    if (isRunning) return;

    isRunning = true;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (seconds > 0) {
          seconds--;
        } else {
          timer.cancel();
          isRunning = false;
        }

        notifyListeners();
      },
    );

    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    isRunning = false;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    seconds = totalSeconds;
    isRunning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}