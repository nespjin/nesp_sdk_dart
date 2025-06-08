// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

class HexUtils {
  HexUtils._();

  static String toHex(Uint8List value) {
    int length;
    if ((length = value.length) <= 0) {
      return '';
    }

    final digital = [
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'A',
      'B',
      'C',
      'D',
      'E',
      'F'
    ];

    Uint8List retBytes = Uint8List(length << 1);
    int i = 0;
    for (int j = 0; j < length; j++) {
      int k = i + 1;
      var index = (value[j] >> 4) & 15;
      retBytes[i] = digital[index].codeUnitAt(0);
      i = k + 1;
      retBytes[k] = digital[value[j] & 15].codeUnitAt(0);
    }
    return String.fromCharCodes(retBytes);
  }

  static int _getCharHex(int c) {
    if (c >= '0'.codeUnitAt(0) && c <= '9'.codeUnitAt(0)) {
      return c - '0'.codeUnitAt(0);
    }
    if (c >= 'A'.codeUnitAt(0) && c <= 'F'.codeUnitAt(0)) {
      return (c - 'A'.codeUnitAt(0)) + 10;
    }
    return 0;
  }

  static Uint8List toBytes(String hex) {
    int length = hex.length;
    if (length % 2 != 0) {
      hex = '0$hex';
      length++;
    }
    List<int> s = hex.toUpperCase().codeUnits;
    Uint8List retBytes = Uint8List(length >> 1);
    for (int i = 0; i < length; i += 2) {
      retBytes[i >> 1] = ((_getCharHex(s[i]) << 4) | _getCharHex(s[i + 1]));
    }
    return retBytes;
  }
}
