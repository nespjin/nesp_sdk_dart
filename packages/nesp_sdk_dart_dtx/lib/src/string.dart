/*
 * Copyright (c) 2023-2023. NESP Technology.
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

import 'package:characters/characters.dart';

extension StringExtension on String {
  bool get isBlank => trim().isEmpty;

  bool get isUrl => startsWith('http://') || startsWith('https://');

  bool get isDigital {
    if (isBlank) {
      return false;
    }

    const regexNumber = '[0-9]*';
    return RegExp(regexNumber).hasMatch(this);
  }

  bool get isEmail {
    if (isBlank) {
      return false;
    }
    const regexEmail =
        "^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}\$";
    return RegExp(regexEmail).hasMatch(this);
  }

  String join(String other, {String separator = ''}) {
    var ret = this;
    if (ret.isNotEmpty && other.isNotEmpty) {
      ret += separator;
    }
    ret += other;
    return ret;
  }

  String ifEmpty(String other) => isEmpty ? other : this;

  String ifBlank(String other) => isBlank ? other : this;

  bool get isChinese => !isBlank && RegExp('[\\u4e00-\\u9fa5]+').hasMatch(this);

  bool get containsChinese {
    String char;
    for (var i = 0; i < characters.length; i++) {
      char = characters.elementAt(i);
      if (char.isChinese) {
        return true;
      }
    }
    return false;
  }

  bool get containsNoAscii {
    String char;
    for (var i = 0; i < characters.length; i++) {
      char = characters.elementAt(i);
      if (char.codeUnitAt(0) > 127) {
        // ASCII's Range 0-127
        return true;
      }
    }
    return false;
  }

  int get charsLength {
    var ret = 0;
    for (var i = 0; i < characters.length; i++) {
      final char = characters.elementAt(i);
      if (char.isChinese) {
        ret += 2;
      } else {
        ret++;
      }
    }
    return ret;
  }
}

extension NullableStringExtension on String? {
  String orEmpty() => or('');

  String or(String other) => this == null ? other : this!;

  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  String ifNullOrEmpty(String other) => isNullOrEmpty ? other : this!;

  String ifNullOrBlank(String other) => isNullOrBlank ? other : this!;
}
