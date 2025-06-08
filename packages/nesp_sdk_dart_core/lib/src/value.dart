// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
