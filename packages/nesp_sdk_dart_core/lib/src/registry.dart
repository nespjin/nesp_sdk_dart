// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Registry<T> {
  final List<T> _items = [];
  final Map<T, Function(T)> _cleaners = {};

  void register(T item, {void Function(T self)? cleaner}) {
    if (_items.contains(item)) return;
    _items.add(item);
    if (cleaner != null) _cleaners[item] = cleaner;
  }

  void unregister(T item) {
    _items.remove(item);
    _cleaners.remove(item);
  }

  List<T> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  void clear() {
    for (var item in _items) {
      _cleaners[item]?.call(item);
    }
    _items.clear();
  }
}
