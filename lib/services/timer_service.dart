import 'dart:async';
import 'dart:ui';

class TimerService {
  late int duration;
  int _remainingTime;
  double progress;
  Timer? _timer;
  bool isRunning = false;

  VoidCallback? onTick;
  VoidCallback? onComplete;

  TimerService({this.duration = 60}) : _remainingTime = duration, progress = 1.0;

  void start() {
    if (isRunning) return;
    isRunning = true;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        progress = _remainingTime / duration;
        onTick?.call(); // 타이머 업데이트
      } else {
        stop();
        onComplete?.call(); // 타이머 완료
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    isRunning = false;
  }

  void reset() {
    stop();
    _remainingTime = duration;
    progress = 1.0;
    onTick?.call();
  }

  String formatTime() {
    final minutes = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final secs = (_remainingTime % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  void dispose() {
    _timer?.cancel();
  }
}
