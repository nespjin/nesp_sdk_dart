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
 * estibulum commodo. Ut rhoncus gravida arcu.
 */

import 'dart:async';

extension StreamExtension<T> on Stream<T> {
  /// Converts a stream to future
  Future<T?> asFuture() async {
    final Completer<T?> completer = Completer();
    final subscription = listen(
      (event) {
        completer.complete(event);
      },
      onError: (error) {
        completer.complete(null);
      },
      cancelOnError: false,
    );

    return completer.future.then((value) {
      subscription.cancel();
      return value;
    }, onError: (error) => subscription.cancel());
  }

  /// Listen event once, will auto-remove listener after event is received.
  Future listenOnce(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
  }) async {
    void Function(Object)? onErrorType1;
    void Function(Object, StackTrace)? onErrorType2;

    if (onError is void Function(Object)) {
      onErrorType1 = onError;
    } else if (onError is void Function(Object, StackTrace)) {
      onErrorType2 = onError;
    }

    if (onError != null && (onErrorType1 == null && onErrorType2 == null)) {
      throw ArgumentError("onError callback must take either an Object "
          "(the error), or both an Object (the error) and a StackTrace.");
    }

    final Completer<T?> completer = Completer();
    final subscription = listen(
      (event) {
        completer.complete(event);
        onData?.call(event);
      },
      onError: (error, stackTrace) {
        completer.complete(null);
        onErrorType1?.call(error);
        onErrorType2?.call(error, stackTrace);
      },
      onDone: onDone,
      cancelOnError: false,
    );

    await completer.future;
    subscription.cancel();
  }
}
