/*
 * Copyright (c) 2023. NESP Technology Corporation. All rights reserved.
 *
 * This program is not free software; you can't redistribute it and/or modify it
 * without the permit of team manager.
 *
 * Unless required by applicable law or agreed to in writing.
 *
 * If you have any questions or if you find a bug,
 * please contact the author by email or ask for Issues.
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
