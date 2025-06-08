// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:nesp_sdk_dart_core/src/date_time.dart';
import 'package:nesp_sdk_dart_core/src/lang/core.dart';
import 'package:stack_trace/stack_trace.dart';

class DebugPrinter {
  DebugPrinter([this.tag = '']);

  static final global = DebugPrinter();

  final String tag;
  bool isEnable = true;

  void print(
    String msg, {
    Object? error,
    StackTrace? stackTrace,
    bool alwaysPrint = false,
  }) {
    assert(() {
      if (isEnable || alwaysPrint) {
        var tag = this.tag;
        if (tag.isEmpty) {
          final trace = Trace.current(1);
          final frame = trace.frames[1];
          tag = '${frame.library}:${frame.line}:${frame.column}';
        }
        msg = '[${formatDateTime(DateTime.now())}\t$tag]\t$msg';
        if (error != null) {
          msg = '$msg\n\t$error';
        }
        if (stackTrace != null) {
          msg = '$msg\n\t${stackTrace.toString().replaceAll('\n', '\n\t')}';
        }
        dartPrint(msg);
      }
      return true;
    }());
  }
}
