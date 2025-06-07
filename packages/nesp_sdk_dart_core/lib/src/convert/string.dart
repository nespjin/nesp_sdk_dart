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
