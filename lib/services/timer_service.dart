import 'dart:async';
import 'dart:ui';

enum TimerMode { countdown, stopwatch }

class TimerService {
  late int duration;
  int _remainingTime;
  double progress;
  Timer? _timer;
  bool isRunning = false;
  TimerMode mode;

  TimerService({this.duration = 60, this.mode = TimerMode.countdown})
      : _remainingTime = duration,
        progress = 1.0;

  // 타이머 상태 변경 리스너
  VoidCallback? onTick;
  VoidCallback? onComplete;

  void start() {
    if (isRunning) return;
    isRunning = true;

    if (mode == TimerMode.countdown) {
      _startCountdown();
    } else if (mode == TimerMode.stopwatch) {
      _startStopwatch();
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        progress = _remainingTime / duration;
        onTick?.call(); // 타이머 업데이트를 알림
      } else {
        stop();
        onComplete?.call(); // 타이머 완료를 알림
      }
    });
  }

  void _startStopwatch() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _remainingTime++;
      onTick?.call(); // 스탑워치 업데이트를 알림
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    isRunning = false;
  }

  void reset() {
    stop();
    if (mode == TimerMode.countdown) {
      _remainingTime = duration;
      progress = 1.0;
    } else if (mode == TimerMode.stopwatch) {
      _remainingTime = 0;
    }
    onTick?.call(); // 리셋 후 상태 업데이트
  }

  String formatTime() {
    final minutes = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final secs = (_remainingTime % 60).toString().padLeft(2, '0');

    if (mode == TimerMode.stopwatch) {
      final milliseconds = (_remainingTime % 1000 ~/ 10).toString().padLeft(2, '0');
      return "$minutes:$secs.$milliseconds";
    } else {
      return "$minutes:$secs";
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
