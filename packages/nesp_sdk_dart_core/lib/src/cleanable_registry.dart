// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'cleanable.dart';
import 'registry.dart';

class CleanableRegistry<T extends Cleanable> extends Registry<T> {
  @override
  void clear() {
    for (var item in items) {
      item.clean();
    }
    super.clear();
  }
}
