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

import 'dart:typed_data';

const _kDebug = false;

class BitSet {
  BitSet(int size) {
    _size = size;

    int byteSize = size;
    if (byteSize % 8 > 0) {
      byteSize = byteSize ~/ 8 + 1;
    } else {
      byteSize = byteSize ~/ 8;
    }
    _data = List.filled(byteSize, 0);
  }

  int _size = 0;
  List<int> _data = [];
  bool _msbAccess = false;

  void toggleAccess() {
    _msbAccess = !_msbAccess;
    // _msbAccess = value;
  }

  bool isLSBAccess() {
    return !_msbAccess;
  }

  bool isMSBAccess() {
    return _msbAccess;
  }

  Uint8List getBytes() {
    return Uint8List.fromList(_data);
  }

  void setBytes(Uint8List bytes) {
    if (_data.length < bytes.length) {
      List<int> newData = List.filled(bytes.length, 0);
      for (var i = 0; i < _data.length; i++) {
        newData[i] = _data[i];
      }
      _data = newData;
    }
    for (var i = 0; i < bytes.length; i++) {
      _data[i] = bytes[i];
    }
  }

  void setBytesAndSize(Uint8List bytes, int size) {
    setBytes(bytes);
    _size = size;
  }

  bool getBit(int index) {
    int usedIndex = _translateIndex(index);
    if (_kDebug) {
      print('Get bit $usedIndex');
    }
    return _data[_byteIndex(usedIndex)] & (0x01 << _bitIndex(usedIndex)) != 0;
  }

  void setBit(int index, bool value) {
    int usedIndex = _translateIndex(index);
    if (_kDebug) {
      print('Set bit $usedIndex');
    }
    int intValue = value ? 1 : 0;
    int byteNum = _byteIndex(usedIndex);
    int bitNum = _bitIndex(usedIndex);
    _data[byteNum] =
        (_data[byteNum] & ~(0x01 << bitNum)) | ((intValue & 0x01) << bitNum);
  }

  int size() {
    return _size;
  }

  void forceSize(int size) {
    if (size > _data.length * 8) {
      throw RangeError.range(size, 0, _data.length * 8);
    } else {
      _size = size;
    }
  }

  int byteSize() {
    return _data.length;
  }

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    for (var i = 0; i < size(); i++) {
      int idx = _doTranslateIndex(i);
      sb.write(
          (_data[_byteIndex(idx)] & 0x01 << _bitIndex(idx)) != 0 ? '1' : '0');
      if ((i + 1) % 8 == 0 && i != size() - 1) {
        sb.write(' ');
      }
    }
    return sb.toString();
  }

  int _byteIndex(int index) {
    if (index < 0 || index >= _data.length * 8) {
      throw RangeError.index(index, _data);
    } else {
      return index ~/ 8;
    }
  }

  int _bitIndex(int index) {
    if (index < 0 || index >= _data.length * 8) {
      throw RangeError.index(index, _data);
    } else {
      return index % 8;
    }
  }

  int _translateIndex(int idx) {
    if (_msbAccess) {
      int mod4 = idx % 4;
      int div4 = idx ~/ 4;
      if (div4 % 2 != 0) {
        // odd
        return idx + _oddOffsets[mod4];
      } else {
        // straight
        return idx + _straightOffsets[mod4];
      }
    } else {
      return idx;
    }
  }

  static int _doTranslateIndex(int idx) {
    int mod4 = idx % 4;
    int div4 = idx ~/ 4;
    if (div4 % 2 != 0) {
      // odd
      return idx + _oddOffsets[mod4];
    } else {
      // straight
      return idx + _straightOffsets[mod4];
    }
  }

  static BitSet createBitSet(Uint8List data, int size) {
    BitSet bitSet = BitSet(data.length * 8);
    bitSet.setBytes(data);
    bitSet._size = size;
    return bitSet;
  }

  static BitSet createBitSet2(Uint8List data) {
    BitSet bitSet = BitSet(data.length * 8);
    bitSet.setBytes(data);
    return bitSet;
  }

  static const List<int> _oddOffsets = [-1, -3, -5, -7];
  static const List<int> _straightOffsets = [7, 5, 3, 1];
}
