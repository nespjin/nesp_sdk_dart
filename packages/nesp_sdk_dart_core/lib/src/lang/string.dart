// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

bool isNullOrEmpty(String? str) => str == null || str.isEmpty;

bool isNullOrBlank(String? str) => str == null || str.trim().isEmpty;

String formatMac(String mac) {
  if (mac.isEmpty) return mac;
  int len = mac.length;
  if (len % 2 != 0) --len;
  if (len == 0) return '';
  final sb = StringBuffer();
  for (var i = 0; i < len; i++) {
    sb.write(mac[i]);
    if (i % 2 == 1 && i != mac.length - 1) {
      sb.write(':');
    }
  }
  return sb.toString();
}
