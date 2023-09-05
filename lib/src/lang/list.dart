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


extension NullableListExtension<E> on List<E>? {
  List<E> or(List<E> other) => this == null ? other : this!;

  List<E> orEmpty() => or(List.empty());
}

extension ListExtension<E> on List<E> {
  E? getOrNull(int index) {
    if (index < 0 || index > length - 1) return null;
    return this[index];
  }
}
