// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

sealed class Result<T, E extends Exception> {
  const Result();

  const factory Result.ok(T value) = Ok._;

  const factory Result.error(Exception error) = Error._;
}

final class Ok<T, E extends Exception> extends Result<T, E> {
  const Ok._(this.value);

  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

final class Error<T, E extends Exception> extends Result<T, E> {
  const Error._(this.error);

  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
