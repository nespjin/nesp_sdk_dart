// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:nesp_sdk_dart_dtx/src/iterable.dart';

extension MapExtension on Map {
  /// Checks if two maps are deeply equal according to specified comparison rules
  ///
  /// [other]: The map to compare with. If null, returns false immediately
  /// [deeply]: When true (default), recursively compares nested collections
  /// [valueEquals]: Optional custom equality function for value comparison.
  ///   When null, uses default '==' operator for values
  ///
  /// Returns true if:
  /// - Both maps have identical key-value pairs (with deep comparison when enabled)
  /// - Both maps are empty (edge case handling)
  /// - References are identical (optimization for same instance)
  bool equals(
    Map? other, {
    bool deeply = true,
    bool Function(Object?, Object?)? valueEquals,
  }) {
    if (other == null) return false;
    if (isEmpty && other.isEmpty) return true;
    if (this == other) return true;
    if (length != other.length) return false;

    for (final MapEntry entry1 in entries) {
      final key1 = entry1.key;
      final value1 = entry1.value;
      if (!other.containsKey(key1)) return false;

      final value2 = other[key1];

      if (deeply) {
        if (value1 is Iterable && value2 is Iterable) {
          if (!value1.equals(value2,
              deeply: deeply, valueEquals: valueEquals)) {
            return false;
          }
          continue;
        }
        if (value1 is Map && value2 is Map) {
          if (!value1.equals(value2,
              deeply: deeply, valueEquals: valueEquals)) {
            return false;
          }
          continue;
        }
      }

      if (valueEquals != null) {
        if (!valueEquals(value1, value2)) return false;
      } else {
        if (value1 != value2) return false;
      }
    }
    return true;
  }

  /// Checks if current map contains all entries from [other] map.
  ///
  /// Performs optional deep comparison for nested collections when [deeply] is true.
  /// Uses [valueEquals] callback for custom value comparison logic when provided.
  ///
  /// [other]: Map to check for containment
  /// [deeply]: (Default: true) Enables recursive comparison for nested Map/Iterable values
  /// [valueEquals]: Optional custom equality function for value comparison
  ///
  /// Returns true if:
  /// - All keys in [other] exist in current map
  /// - All corresponding values satisfy equality check (either via [valueEquals],
  ///   deep structural equality when [deeply]=true, or standard == operator)
  bool contains(
    Map? other, {
    bool deeply = true,
    bool Function(Object?, Object?)? valueEquals,
  }) {
    if (other == null) return false;
    if (isEmpty) return false; // Non-empty other can't be in empty map
    if (other.isEmpty) return true; // Empty other is always contained

    // Check if all keys in other exist in this map
    for (final key in other.keys) {
      if (!containsKey(key)) return false;
    }

    final map1 = Map.from(this);
    final map2 = Map.from(other);

    for (final entity in map2.entries) {
      final key2 = entity.key;
      final value1 = map1[key2];
      final value2 = entity.value;

      if (deeply) {
        if (value1 is Map && value2 is Map) {
          if (!value1.contains(value2,
              deeply: deeply, valueEquals: valueEquals)) {
            return false;
          }
          continue;
        }

        if (value1 is Iterable && value2 is Iterable) {
          if (!value1.equals(value2,
              deeply: deeply, valueEquals: valueEquals)) {
            return false;
          }
          continue;
        }
      }

      if (valueEquals != null) {
        if (!valueEquals(value1, value2)) return false;
      } else {
        if (value1 != value2) return false;
      }
    }

    return true;
  }

  /// Set the other's value that key exists in this map.
  void setAll(Map? other, {bool deeply = true}) {
    if (other == null || other.isEmpty) return;
    final keys = this.keys.where((key) => other.containsKey(key));
    for (final key in keys) {
      final value1 = this[key];
      final value2 = other[key];
      if (deeply && value1 is Map && value2 is Map) {
        value1.setAll(value2, deeply: deeply);
      } else {
        this[key] = value2;
      }
    }
  }

  /// Merges the current map with [other] map, optionally performing deep merging.
  ///
  /// If [deeply] is true, nested maps will be recursively merged.
  /// When conflicting keys exist, values from [other] take precedence,
  /// except for nested maps which are merged when [deeply] is enabled.
  ///
  /// Parameters:
  ///   [other]: The map to merge with. If null or empty, returns original map.
  ///   [deeply]: Controls whether to merge nested maps (default: true).
  ///
  /// Returns:
  ///   A new merged [Map] containing combined key-value pairs. Original maps remain unmodified.
  Map merge(Map? other, {bool deeply = true}) {
    if (other == null || other.isEmpty) return Map.from(this);
    if (isEmpty) return Map.from(other);

    final ret = Map.from(this);
    ret.addAll(other);
    final keys = [...this.keys, ...other.keys];
    for (final key in keys) {
      final value1 = this[key];
      final value2 = other[key];
      if (deeply && value1 is Map && value2 is Map) {
        ret[key] = value1.merge(value2, deeply: deeply);
      }
    }
    return ret;
  }

  /// Computes the intersection of two maps, optionally performing deep comparison.
  ///
  /// This function returns a new map containing only the key-value pairs that are present
  /// in both the current map and the [other] map. The comparison can be performed deeply
  /// for nested maps and iterables, and a custom equality function can be provided for
  /// comparing values.
  ///
  /// Parameters:
  ///   - [other]: The map to intersect with the current map. If null or empty, an empty map is returned.
  ///   - [deeply]: If true, performs deep comparison for nested maps and iterables. Defaults to true.
  ///   - [valueEquals]: An optional function to compare values. If not provided, the default equality operator (`==`) is used.
  ///
  /// Returns:
  ///   A new map containing the intersection of the current map and the [other] map.
  Map intersect(Map? other,
      {bool deeply = true, bool Function(Object?, Object?)? valueEquals}) {
    if (isEmpty || other == null || other.isEmpty) return {};

    final ret = Map.from(this)
      ..removeWhere((key, value) => !other.containsKey(key));
    final keys = ret.keys.toSet();

    for (final key in keys) {
      final value1 = this[key];
      final value2 = other[key];
      if (value1 is Map && value2 is Map) {
        if (deeply) {
          ret[key] = value1.intersect(value2, deeply: deeply);
        } else if (!value1.equals(value2,
            deeply: true, valueEquals: valueEquals)) {
          ret.remove(key);
        }
        continue;
      }

      if (value1 is Iterable && value2 is Iterable) {
        if (!value1.equals(value2, deeply: deeply, valueEquals: valueEquals)) {
          ret.remove(key);
        }
        continue;
      }

      if (valueEquals != null) {
        if (!valueEquals(value1, value2)) ret.remove(key);
      } else {
        if (value1 != value2) ret.remove(key);
      }
    }
    return ret;
  }

  /// Computes the difference between this map and another map.
  ///
  /// This function returns a new map containing the key-value pairs that are present
  /// in this map but not in the other map. The comparison can be performed deeply
  /// for nested maps and iterables, and a custom equality function can be provided
  /// for comparing values.
  ///
  /// [other]: The map to compare against. If null or empty, the function returns
  ///          a copy of this map.
  /// [deeply]: If true, performs a deep comparison for nested maps and iterables.
  ///           Defaults to true.
  /// [valueEquals]: A custom function to compare values. If not provided, the default
  ///                equality operator (`==`) is used.
  ///
  /// Returns a new map containing the differences.
  Map difference(Map? other,
      {bool deeply = true, bool Function(Object?, Object?)? valueEquals}) {
    if (other == null || other.isEmpty) return Map.from(this);
    if (isEmpty) return Map.from(other);
    final ret = Map.from(
        this) /* ..removeWhere((key, value) => other.containsKey(key))*/;

    for (final key in keys) {
      final value1 = this[key];
      final value2 = other[key];
      if (value1 is Map && value2 is Map) {
        if (deeply) {
          final difference = value1.difference(value2, deeply: deeply);
          if (difference.isEmpty) {
            ret.remove(key);
          } else {
            ret[key] = difference;
          }
        } else if (value1.equals(value2,
            deeply: true, valueEquals: valueEquals)) {
          ret.remove(key);
        }
        continue;
      }

      if (value1 is Iterable && value2 is Iterable) {
        if (value1.equals(value2, deeply: deeply, valueEquals: valueEquals)) {
          ret.remove(key);
        }
        continue;
      }

      if (valueEquals != null) {
        if (valueEquals(value1, value2)) ret.remove(key);
      } else {
        if (value1 == value2) ret.remove(key);
      }
    }
    return ret;
  }
}
