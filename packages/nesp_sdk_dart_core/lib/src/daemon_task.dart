// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
