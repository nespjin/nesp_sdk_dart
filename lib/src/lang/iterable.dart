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

import 'dart:math';

extension NullableIterableExtension<E> on Iterable<E>? {
  Iterable<E> or(Iterable<E> other) => this == null ? other : this!;

  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

extension IterableExtension<E> on Iterable<E> {
  /// Returns the first element.
  ///
  /// Returns [other] if `this` is empty.
  /// Otherwise returns the first element in the iteration order,
  /// equivalent to `this.elementAt(0)`.
  E firstOr(E other) {
    Iterator<E> it = iterator;
    if (!it.moveNext()) {
      return other;
    }
    return it.current;
  }

  /// Returns the first element.
  ///
  /// Returns null if `this` is empty.
  /// Otherwise returns the first element in the iteration order,
  /// equivalent to `this.elementAt(0)`.
  E? get firstOrNull {
    Iterator<E> it = iterator;
    if (!it.moveNext()) {
      return null;
    }
    return it.current;
  }

  /// Returns the last element.
  ///
  /// Returns [other] if `this` is empty.
  /// Otherwise may iterate through the elements and returns the last one
  /// seen.
  /// Some iterables may have more efficient ways to find the last element
  /// (for example a list can directly access the last element,
  /// without iterating through the previous ones).
  E lastOr(E other) {
    Iterator<E> it = iterator;
    if (!it.moveNext()) {
      return other;
    }
    E result;
    do {
      result = it.current;
    } while (it.moveNext());
    return result;
  }

  /// Returns the last element.
  ///
  /// Returns null if `this` is empty.
  /// Otherwise may iterate through the elements and returns the last one
  /// seen.
  /// Some iterables may have more efficient ways to find the last element
  /// (for example a list can directly access the last element,
  /// without iterating through the previous ones).
  E? get lastOrNull {
    Iterator<E> it = iterator;
    if (!it.moveNext()) {
      return null;
    }
    E result;
    do {
      result = it.current;
    } while (it.moveNext());
    return result;
  }

  /// Returns the first element that satisfies the given predicate [test].
  ///
  /// Iterates through elements and returns the first to satisfy [test].
  ///
  /// Example:
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 5, 6, 7];
  /// var result = numbers.firstWhere((element) => element < 5); // 1
  /// result = numbers.firstWhere((element) => element > 5); // 6
  /// result =
  ///     numbers.firstWhere((element) => element > 10, orElse: () => -1); // -1
  /// ```
  ///
  /// If no element satisfies [test], the result of invoking the [orElse]
  /// function is returned.
  /// If [orElse] is omitted, it defaults to return null.
  E? firstNullableWhere(bool Function(E element) test, {E Function()? orElse}) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return orElse?.call();
  }

  /// Returns the last element that satisfies the given predicate [test].
  ///
  /// An iterable that can access its elements directly may check its
  /// elements in any order (for example a list starts by checking the
  /// last element and then moves towards the start of the list).
  /// The default implementation iterates elements in iteration order,
  /// checks `test(element)` for each,
  /// and finally returns that last one that matched.
  ///
  /// Example:
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 5, 6, 7];
  /// var result = numbers.lastWhere((element) => element < 5); // 3
  /// result = numbers.lastWhere((element) => element > 5); // 7
  /// result = numbers.lastWhere((element) => element > 10,
  ///     orElse: () => -1); // -1
  /// ```
  ///
  /// If no element satisfies [test], the result of invoking the [orElse]
  /// function is returned.
  /// If [orElse] is omitted, it defaults to return null.
  E? lastNullableWhere(bool Function(E element) test, {E Function()? orElse}) {
    late E result;
    bool foundMatching = false;
    for (E element in this) {
      if (test(element)) {
        result = element;
        foundMatching = true;
      }
    }
    if (foundMatching) return result;
    if (orElse != null) return orElse();
    return null;
  }

  num sumOf(num Function(E element) numTransform) {
    Iterator<E> it = iterator;
    if (!it.moveNext()) {
      return 0;
    }
    num result = 0;
    do {
      result += numTransform(it.current);
    } while (it.moveNext());
    return result;
  }

  num maxOf(num Function(E element) numTransform) {
    Iterator<E> it = iterator;
    if (!it.moveNext()) {
      return 0;
    }
    num result = 0;
    do {
      result = max(numTransform(it.current), result);
    } while (it.moveNext());
    return result;
  }

  num minOf(num Function(E element) numTransform) {
    Iterator<E> it = iterator;
    if (!it.moveNext()) {
      return 0;
    }
    num result = 0;
    do {
      result = min(numTransform(it.current), result);
    } while (it.moveNext());
    return result;
  }
}
