// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

extension NumExtension on num {
  String toStringAsTrialingZeros(int fractionDigits) {
    if (this == 0) {
      return '0';
    }

    var ret = toStringAsFixed(fractionDigits);
    var length = ret.length;
    while (
        ret.contains('.') && ret.codeUnitAt(length - 1) == '0'.codeUnitAt(0)) {
      length--;
      if (length <= 0) {
        break;
      }
    }

    if (ret.codeUnitAt(length - 1) == '.'.codeUnitAt(0)) {
      length--;
    }

    if (length > 0 && length < ret.length) {
      ret = ret.substring(0, length);
    }

    return ret;
  }
}
