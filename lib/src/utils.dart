/*
 * Copyright (c) 2023. NESP Technology Corporation. All rights reserved.
 *
 * This program is not free software; you can't redistribute it and/or modify it
 * without the permit of team manager.
 *
 * Unless required by applicable law or agreed to in writing.
 *
 * If you have any questions or if you find a bug,
 * please contact the author by email or ask for Issues.
 */

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
