/*
 * Copyright (c) 2023-2023. NESP Technology.
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

  Stream<D> whereType<D>() {
    return where((element) => element is D).map((event) => event as D);
  }
}
