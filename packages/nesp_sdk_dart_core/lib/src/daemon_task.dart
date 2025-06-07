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

const int daemonTaskStateIdle = 0;
const int daemonTaskStateRunning = 1;
const int daemonTaskStatePaused = 2;
const int daemonTaskStateStopped = 3;

abstract base class DaemonTask {
  DaemonTask(this.name);

  final String name;

  int _state = daemonTaskStateIdle;

  int get state => _state;

  set state(int value) {
    if (_state == daemonTaskStateStopped) {
      return;
    }
    _state = value;
  }

  FutureOr<void> run();

  void pause() {
    _state = daemonTaskStatePaused;
  }

  void stop() {
    _state = daemonTaskStateStopped;
  }
}
