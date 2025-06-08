// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

Function() debounce(Function() work, Duration duration) {
  Timer? timer;
  return () {
    timer?.cancel();
    timer = null;

    timer = Timer(duration, work);
  };
}

Function() throttle(Function() work, Duration duration) {
  bool burial = false;
  return () {
    if (burial) {
      return;
    }
    burial = true;
    Timer(duration, () {
      work();
      burial = false;
    });
  };
}
