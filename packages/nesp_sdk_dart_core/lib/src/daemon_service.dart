import 'dart:async';

import 'package:nesp_sdk_dart_core/nesp_sdk_dart_core.dart';

const int kDaemonTaskStateIdle = 0;
const int kDaemonTaskStateRunning = 1;
const int kDaemonTaskStatePaused = 2;
const int kDaemonTaskStateStopped = 3;

abstract base class DaemonTask {
  DaemonTask(this.name);

  final String name;

  int _state = kDaemonTaskStateIdle;

  int get state => _state;

  void _setState(int value) {
    if (_state == kDaemonTaskStateStopped) {
      return;
    }
    _state = value;
  }

  FutureOr<void> run();

  void pause() {
    _state = kDaemonTaskStatePaused;
  }

  void resume() {
    _state = kDaemonTaskStateIdle;
  }

  void stop() {
    _state = kDaemonTaskStateStopped;
  }
}

class DaemonService {
  DaemonService([this.interval = const Duration(seconds: 3)]);

  final Duration interval;

  Timer? _timer;
  final Set<DaemonTask> _tasks = {};

  void start() {
    if (_timer?.isActive ?? false) return;
    _timer = Timer.periodic(interval, _work);
  }

  void addTask(DaemonTask task) {
    _tasks.add(task);
  }

  void removeTask(DaemonTask task) {
    _tasks.remove(task);
  }

  void clearTask() {
    _tasks.clear();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _work(Timer timer) {
    for (final task in _tasks) {
      _runTask(task);
    }
  }

  void _runTask(DaemonTask task) {
    if (task.state == kDaemonTaskStatePaused) {
      return;
    }

    if (task.state == kDaemonTaskStateStopped) {
      removeTask(task);
      return;
    }

    if (task.state == kDaemonTaskStateIdle) {
      task._setState(kDaemonTaskStateRunning);
      try {
        debugLogPrinter('daemon_service: running task(${task.name}).');
        var ret = task.run();
        if (ret is Future) {
          ret.onError((error, stackTrace) {
            debugLogPrinter(
                'daemon_service: error occurred while running async '
                'task(${task.name}).');
            debugLogPrinter(error?.toString(), stackTrace: stackTrace);
          }).whenComplete(() {
            if (task.state == kDaemonTaskStateRunning) {
              task._setState(kDaemonTaskStateIdle);
            }
          });
        } else {
          task._setState(kDaemonTaskStateIdle);
        }
      } catch (error) {
        debugLogPrinter('daemon_service: error occurred while running '
            'task(${task.name}).');
        debugLogPrinter(error.toString());
        if (task.state == kDaemonTaskStateRunning) {
          task._setState(kDaemonTaskStateIdle);
        }
      }
      return;
    }
  }
}
