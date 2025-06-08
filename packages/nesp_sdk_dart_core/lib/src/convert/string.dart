// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

class StringUtils {
  const StringUtils._();

  static String asciiDecode(Uint8List bytes) {
    return _decode(ascii.decode, bytes);
  }

  static String utf8Decode(Uint8List bytes) {
    return _decode(utf8.decode, bytes);
  }

  static String _decode(
      String Function(List<int> bytes) decode, Uint8List bytes) {
    String value = decode(bytes);
    String ret = '';
    for (var char in value.codeUnits) {
      if (char == 0x00) {
        ret += '';
      } else {
        ret += decode([char]);
      }
    }
    return ret;
  }
}
