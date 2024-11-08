import 'dart:async';
import 'dart:ui';

class StopwatchService {
  int _elapsedTime = 0;
  Timer? _timer;
  bool isRunning = false;

  VoidCallback? onTick;

  void start() {
    if (isRunning) return;
    isRunning = true;
    _startStopwatch();
  }

  void _startStopwatch() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      _elapsedTime += 10;
      onTick?.call(); // 스탑워치 업데이트
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    isRunning = false;
  }

  void reset() {
    stop();
    _elapsedTime = 0;
    onTick?.call();
  }

  String formatTime() {
    final minutes = (_elapsedTime ~/ 60000).toString().padLeft(2, '0');
    final secs = ((_elapsedTime ~/ 1000) % 60).toString().padLeft(2, '0');
    final milliseconds = ((_elapsedTime % 1000) ~/ 10).toString().padLeft(2, '0');
    return "$minutes:$secs.$milliseconds";
  }

  void dispose() {
    _timer?.cancel();
  }
}
