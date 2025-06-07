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
