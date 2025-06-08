// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

class StreamSubscriptionRegistry {
  final List<StreamSubscription> _subscriptions = [];

  void register(StreamSubscription subscription) {
    if (_subscriptions.contains(subscription)) return;
    _subscriptions.add(subscription);
  }

  void unregister(StreamSubscription subscription) {
    _subscriptions.remove(subscription);
  }

  Future<void> cancel(StreamSubscription subscription) async {
    await subscription.cancel();
    _subscriptions.remove(subscription);
  }

  Future<void> cancelAll() async {
    await Future.wait(_subscriptions.map((e) => e.cancel()));
    _subscriptions.clear();
  }
}
