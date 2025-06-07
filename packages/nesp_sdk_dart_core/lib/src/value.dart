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
import 'dart:async';

typedef Lazy<T> = T Function();

class Value<T> {
  Value({
    T? value,
    Lazy? lazy,
    this.test,
  })  : _value = value,
        _lazy = lazy;

  T get value {
    return valueOrNull!;
  }

  Value.lazy(Lazy lazy, {this.test}) : _lazy = lazy;

  Value.of(T value, {this.test}) : _value = value;

  Value.nullable(this._value, {this.test});

  Stream<T> get stream {
    _streamController ??= StreamController.broadcast();
    return _streamController!.stream;
  }

  Future close() async {
    return await _streamController?.close();
  }

  T? get valueOrNull {
    var ret = _value;
    final lazy = _lazy;

    if (ret != null) return ret;

    if (lazy != null) {
      ret = lazy();
      _lazy = null;
    }

    _value = ret;
    return ret;
  }

  set value(T v) {
    _lastValue = _value;
    _value = v;
    _streamController?.add(v);
  }

  T? get lastValue => _lastValue;

  bool get isChanged {
    final last = _lastValue;
    final cur = _value;
    if (cur == null && last != null) return true;
    if (cur != null && last == null) return true;
    if (cur == null && last == null) return false;
    if (cur is List && last is List && cur.length != last.length) {
      return true;
    }
    if (cur is Map && last is Map && cur.length != last.length) {
      return true;
    }
    if (cur is Set && last is Set && cur.length != last.length) {
      return true;
    }
    return test == null ? cur != last : test!(cur as T, last as T);
  }

  Lazy? _lazy;

  T? _value;

  StreamController<T>? _streamController;

  T? _lastValue;

  bool Function(T oldValue, T newValue)? test;
}
