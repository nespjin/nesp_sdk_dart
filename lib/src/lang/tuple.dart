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

class Pair<A, B> {
  const Pair({
    required this.first,
    required this.second,
  });

  final A first;
  final B second;

  @override
  String toString() => '($first,$second)';
}

class Triple<A, B, C> {
  const Triple({
    required this.first,
    required this.second,
    required this.third,
  });

  final A first;
  final B second;
  final C third;

  @override
  String toString() => '($first,$second,$third)';
}
