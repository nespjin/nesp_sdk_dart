import 'dart:async';

final class StreamSubscriptionRegistry {
  StreamSubscriptionRegistry();

  final List<StreamSubscription> _subscriptions = [];

  void register(StreamSubscription subscription) {
    if (_subscriptions.contains(subscription)) return;
    _subscriptions.add(subscription);
  }

  void unregister(StreamSubscription subscription) {
    _subscriptions.remove(subscription);
  }

  Future<void> cancelAll() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }
}
