// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

typedef DebugLogPrinter = void Function(String? message,
    {StackTrace? stackTrace});

DebugLogPrinter debugLogPrinter = _defaultDebugLogPrinter;

void _defaultDebugLogPrinter(String? message, {StackTrace? stackTrace}) {
  assert(() {
    print(message);
    if (stackTrace != null) print(stackTrace);
    return true;
  }());
}
