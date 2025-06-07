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
