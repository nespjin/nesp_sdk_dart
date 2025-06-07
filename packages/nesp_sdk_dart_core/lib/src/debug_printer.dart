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
