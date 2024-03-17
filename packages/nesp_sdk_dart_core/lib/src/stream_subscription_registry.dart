import 'dart:async';

final class StreamSubscriptionRegistry {
  StreamSubscriptionRegistry();

  final List<StreamSubscription> _subscriptions = [];

  void register(StreamSubscription subscription) {
    if(_subscriptions.contains(subscription)) return;
    _subscriptions.add(subscription);
  }

  void unregister(StreamSubscription subscription) {
    _subscriptions.remove(subscription);
  }

  void cancelAll() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
