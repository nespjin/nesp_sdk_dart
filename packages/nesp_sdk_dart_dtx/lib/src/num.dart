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
extension NumExtension on num {
  String toStringAsTrialingZeros(int fractionDigits) {
    if (this == 0) {
      return '0';
    }

    var ret = toStringAsFixed(fractionDigits);
    var length = ret.length;
    while (
        ret.contains('.') && ret.codeUnitAt(length - 1) == '0'.codeUnitAt(0)) {
      length--;
      if (length <= 0) {
        break;
      }
    }

    if (ret.codeUnitAt(length - 1) == '.'.codeUnitAt(0)) {
      length--;
    }

    if (length > 0 && length < ret.length) {
      ret = ret.substring(0, length);
    }

    return ret;
  }
}
