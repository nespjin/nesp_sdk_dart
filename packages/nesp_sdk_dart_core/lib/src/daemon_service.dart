/*
 * Copyright (c) 2023. NESP Technology.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License. You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License
 * for the specific language governing permissions and limitations under the License.
 *
 */
import 'dart:async';

import 'package:nesp_sdk_dart_core/src/debug_printer.dart';

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

  final DebugPrinter _debugPrinter = DebugPrinter('DaemonService');

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
        _debugPrinter.print('daemon_service: running task(${task.name}).');
        var ret = task.run();
        if (ret is Future) {
          ret.onError((error, stackTrace) {
            _debugPrinter.print(
                'daemon_service: error occurred while running async '
                'task(${task.name}).',
                error: error,
                stackTrace: stackTrace,
                alwaysPrint: true);
          }).whenComplete(() {
            if (task.state == kDaemonTaskStateRunning) {
              task._setState(kDaemonTaskStateIdle);
            }
          });
        } else {
          task._setState(kDaemonTaskStateIdle);
        }
      } catch (error) {
        _debugPrinter.print(
            'daemon_service: error occurred while running '
            'task(${task.name}).',
            error: error,
            alwaysPrint: true);
        if (task.state == kDaemonTaskStateRunning) {
          task._setState(kDaemonTaskStateIdle);
        }
      }
      return;
    }
  }
}
