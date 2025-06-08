// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class NespException implements Exception {
  const NespException([this.message = '']) : parent = null;

  NespException.from([this.parent]) : message = '';

  final Exception? parent;
  final String message;

  @override
  String toString() {
    if (parent != null) {
      return 'NespException[parent=\'${parent.toString()}\']';
    }
    return 'NespException[message=\'$message\']';
  }
}
