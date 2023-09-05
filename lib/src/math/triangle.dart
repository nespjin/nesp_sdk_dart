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

/// A base class for representing two-dimensional axis-aligned triangles.
///
/// This triangle uses a left-handed Cartesian coordinate system, with x
/// directed to the right and y directed down, as per the convention in 2D
/// computer graphics.
///
/// See also:
///    [W3C Coordinate Systems Specification](https://www.w3.org/TR/SVG/coords.html#InitialCoordinateSystem).
abstract class _TriangleBase<T extends num> {
  const _TriangleBase();

  /// The left point of the triangle.
  Point<T> get leftPoint;

  /// The top point of the triangle.
  Point<T> get topPoint;

  /// The right point of the triangle.
  Point<T> get rightPoint;

  @override
  String toString() {
    return 'Triangle(leftPoint: (${leftPoint.x},${leftPoint.y}),(${topPoint.x},${topPoint.y}),(${rightPoint.x},${rightPoint.y}),)';
  }

  @override
  bool operator ==(Object other) =>
      other is _TriangleBase &&
      leftPoint == other.leftPoint &&
      topPoint == other.topPoint &&
      rightPoint == other.rightPoint;

  @override
  int get hashCode => Object.hash(leftPoint, topPoint, rightPoint);
}

class Triangle<T extends num> extends _TriangleBase<T> {
  const Triangle(this.leftPoint, this.topPoint, this.rightPoint);

  @override
  final Point<T> leftPoint;

  @override
  final Point<T> topPoint;

  @override
  final Point<T> rightPoint;

  /// Equilateral triangle which bottom edge is horizontal, and the vertices are on top.
  factory Triangle.equilateral(Point<T> leftPoint, T sideLength) {
    T x, y;
    x = leftPoint.x + sideLength as T;
    y = leftPoint.y;
    final Point<T> rightPoint = Point<T>(x, y);

    x = leftPoint.x + (sideLength / 2) as T;
    y = leftPoint.y - (pow(3, 0.5) / 2 as T) * sideLength as T;
    final Point<T> topPoint = Point<T>(x, y);
    return Triangle<T>(leftPoint, topPoint, rightPoint);
  }

  /// Isosceles triangle which bottom edge is horizontal, and the vertices are on top.
  factory Triangle.isosceles(
      Point<T> leftPoint, T sidewaysLength, T bottomSideLength) {
    T x, y;
    x = leftPoint.x + bottomSideLength as T;
    y = leftPoint.y;
    final Point<T> rightPoint = Point<T>(x, y);

    x = leftPoint.x + (bottomSideLength / 2) as T;
    y = leftPoint.y -
        pow(pow(sidewaysLength, 2) - pow((bottomSideLength / 2), 2), 0.5) as T;
    final Point<T> topPoint = Point<T>(x, y);
    return Triangle<T>(leftPoint, topPoint, rightPoint);
  }

  /// The vertical direction is reversed,
  /// and the triangle must be horizontal at the base.
  Triangle<T> flipVertically() {
    if (leftPoint.y != rightPoint.y) {
      return this;
    }
    final T i = (this.topPoint.y - this.leftPoint.y) as T;
    final topPoint = Point<T>(this.topPoint.x, this.leftPoint.y - i as T);
    return Triangle<T>(this.leftPoint, topPoint, this.rightPoint);
  }
}
