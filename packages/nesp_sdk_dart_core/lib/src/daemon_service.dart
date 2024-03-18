import 'dart:async';

import 'package:nesp_sdk_dart_core/nesp_sdk_dart_core.dart';

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
    if (task.state == daemonTaskStatePaused) {
      return;
    }

    if (task.state == daemonTaskStateStopped) {
      removeTask(task);
      return;
    }

    if (task.state == daemonTaskStateIdle) {
      task.state = daemonTaskStateRunning;
      try {
        debugLogPrinter('daemon_service: running task(${task.name}).');
        var ret = task.run();
        if (ret is Future) {
          ret
              .then((value) => task.state = daemonTaskStateIdle)
              .onError((error, stackTrace) {
            print('daemon_service: error occurred while running async '
                'task(${task.name}).');
            debugLogPrinter(error?.toString(), stackTrace: stackTrace);
            return task.state = daemonTaskStateIdle;
          });
        } else {
          task.state = daemonTaskStateIdle;
        }
      } catch (error) {
        debugLogPrinter('daemon_service: error occurred while running '
            'task(${task.name}).');
        debugLogPrinter(error.toString());
        task.state = daemonTaskStateIdle;
      }
      return;
    }
  }
}
