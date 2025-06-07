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
