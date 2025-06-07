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
