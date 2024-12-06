import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/pomodoro_service.dart';

class StopwatchService extends TimerService {
  int _elapsedSeconds = 0;
  Timer? _timer;
  DateTime? _startTime;
  DateTime? _backgroundTime;
  bool _hasUpdatedFirestore = false; // Firestore 업데이트 여부 플래그

  int getElapsedSecondsForFirestore() {
    return elapsedTimeForFirestore;
  }

  StopwatchService() : super(pomodoroDuration: 0, breakDuration: 0) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void start() {
    if (isRunning) return;
    isRunning = true;
    _hasUpdatedFirestore = false; // 새 세션 시작 시 Firestore 상태 초기화
    _startTime = DateTime.now().subtract(Duration(seconds: _elapsedSeconds));
    _startStopwatch();
  }

  void _startStopwatch() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        final now = DateTime.now();
        _elapsedSeconds = now.difference(_startTime!).inSeconds;
        elapsedTimeForFirestore++; // Firestore용 경과 시간 증가
        elapsedTimeForUI++;        // UI용 경과 시간 증가
        progress = 1.0;
        onTick?.call();
      }
    });
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
    isRunning = false;
  }

  @override
  void reset() {
    stop();
    _elapsedSeconds = 0;
    elapsedTimeForUI = 0;
    elapsedTimeForFirestore = 0; // Firestore용 시간도 초기화
    progress = 1.0;
    onTick?.call();
    _hasUpdatedFirestore = false; // 초기화 시 업데이트 상태 리셋
  }

  @override
  String formatTime() {
    final hours = (_elapsedSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_elapsedSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');

    // 시간이 0인 경우 분:초만 표시
    if (hours == '00') {
      return '$minutes:$seconds';
    }
    // 시간이 있는 경우 시:분:초 표시
    return '$hours:$minutes:$seconds';
  }

  // TimerService와의 호환성을 위한 오버라이드
  @override
  String formatElapsedTime(int elapsedSeconds) {
    return formatTime();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}
