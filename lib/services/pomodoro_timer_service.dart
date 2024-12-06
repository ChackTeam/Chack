import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chack_project/services/daily_reading_service.dart';
import 'package:chack_project/services/notification_service.dart';

class TimerService with WidgetsBindingObserver {
  final DailyReadingService _dailyReadingService = DailyReadingService();
  final int pomodoroDuration;
  final int breakDuration;
  late int duration;
  late int _remainingTime;
  int elapsedTimeForFirestore = 0;
  int elapsedTimeForUI = 0;
  double progress;
  Timer? _timer;
  bool isRunning = false;
  bool isPomodoro = true;
  String? _userId;

  VoidCallback? onTick;
  VoidCallback? onComplete;

  TimerService({
    this.pomodoroDuration = 10,
    this.breakDuration = 5,
  })  : duration = pomodoroDuration,
        _remainingTime = pomodoroDuration,
        progress = 1.0 {
    WidgetsBinding.instance.addObserver(this);
  }

  void start() {
    if (isRunning) return;
    isRunning = true;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        if (isPomodoro) {
          elapsedTimeForFirestore++;
          elapsedTimeForUI++;
        }
        progress = _remainingTime / duration;
        onTick?.call();
      } else {
        stop();
        _handleTimerComplete();
      }
    });
  }

  void _handleTimerComplete() async {
    if (isPomodoro) {
      // 뽀모도로 타이머가 끝났을 때
      if (_userId != null) {
        await updateDailyReadingTime(userId: _userId!);
      }
      await NotificationService.showReadingCompleteNotification(pomodoroDuration);
      onComplete?.call();
      switchTimer(); // 휴식 타이머로 전환
      start(); // 휴식 타이머 시작
    } else {
      // 휴식 타이머가 끝났을 때
      await NotificationService.showBreakCompleteNotification();
      onComplete?.call();
      switchTimer(); // 다시 뽀모도로 타이머로 전환
      // 여기서는 자동으로 시작하지 않음
      reset(); // 타이머를 초기 상태로 리셋
    }
  }

  void pause() {
    if (!isRunning) return;
    _timer?.cancel();
    _timer = null;
    isRunning = false;
  }

  void switchTimer() {
    if (isPomodoro) {
      duration = breakDuration;
      elapsedTimeForFirestore = 0;
      elapsedTimeForUI = 0;
    } else {
      duration = pomodoroDuration;
    }
    _remainingTime = duration;
    progress = 1.0;
    isPomodoro = !isPomodoro;
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    isRunning = false;
  }

  void reset() {
    stop();
    elapsedTimeForFirestore = 0;
    elapsedTimeForUI = 0;
    _remainingTime = duration;
    progress = 1.0;
    onTick?.call();
  }

  String formatElapsedTime(int elapsedSeconds) {
    final duration = Duration(seconds: elapsedSeconds);
    return '${duration.inMinutes}분 ${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}초';
  }

  String formatTime() {
    final minutes = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> updateDailyReadingTime({
    required String userId,
  }) async {
    if (elapsedTimeForFirestore > 0) {
      try {
        await _dailyReadingService.updateDailyReadingTime(
          userId: userId,
          seconds: elapsedTimeForFirestore,
          date: DateTime.now(),
        );
        elapsedTimeForFirestore = 0;
      } catch (e) {
        print('Error updating daily reading time: $e');
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }
}