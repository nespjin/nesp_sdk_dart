// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'handler.dart';
import 'message.dart';
import 'runnable.dart';
import 'looper.dart';

///
/// Ported from AOSP Project ```frameworks/base/core/java/android/os/MessageQueue.java```
///

/// Low-level class holding the list of messages to be dispatched by a
/// [Looper].  Messages are not added directly to a MessageQueue,
/// but rather through {@link Handler} objects associated with the Looper.
///
/// <p>You can retrieve the MessageQueue for the current thread with
/// {@link Looper#myQueue() Looper.myQueue()}.
class MessageQueue {
  static const _kTag = 'MessageQueue';
  static const _kDebug = false;

  // True if the message queue can be quit.
  final bool _quitAllowed;
  Message? _messages;
  final _idleHandlers = <IdleHandler>[];
  List<IdleHandler?>? _pendingIdleHandlers;

  bool _quitting = false;

  /// Indicates whether next() is blocked waiting in pollOnce() with a non-zero timeout.
  bool _blocked = false;

  /// The next barrier token.
  /// Barriers are indicated by messages with a null target whose arg1 field carries the token.
  int _nextBarrierToken = 0;

  Completer<void>? _pollLocker;

  MessageQueue(bool quitAllowed) : _quitAllowed = quitAllowed;

  /// Disposes of the underlying message queue.
  /// Must only be called on the looper thread or the finalizer.
  void _dispose() {}

  /// Returns true if the looper has no pending messages which are due to be processed.
  ///
  /// <p>This method is safe to call from any thread.
  ///
  /// @return True if the looper is idle.
  bool isIdle() {
    final messages = _messages;
    final now = DateTime.now().microsecondsSinceEpoch;
    return messages == null || now < messages.when;
  }

  /// Add a new [IdleHandler] to this message queue.  This may be
  /// removed automatically for you by returning false from
  /// {@link IdleHandler#queueIdle IdleHandler.queueIdle()} when it is
  /// invoked, or explicitly removing it with {@link #removeIdleHandler}.
  ///
  /// <p>This method is safe to call from any thread.
  ///
  /// [handler] The IdleHandler to be added.
  void addIdleHandler(IdleHandler handler) {
    _idleHandlers.add(handler);
  }

  /// Remove an [IdleHandler] from the queue that was previously added
  /// with [addIdleHandler].  If the given object is not currently
  /// in the idle list, nothing is done.
  ///
  /// <p>This method is safe to call from any thread.
  ///
  /// [handler] The IdleHandler to be removed.
  void removeIdleHandler(IdleHandler handler) {
    _idleHandlers.remove(handler);
  }

  /// Returns whether this looper's thread is currently polling for more work to do.
  /// This is a good signal that the loop is still alive rather than being stuck
  /// handling a callback.  Note that this method is intrinsically racy, since the
  /// state of the loop can change before you get the result back.
  ///
  /// <p>This method is safe to call from any thread.
  ///
  /// @return True if the looper is currently polling for events.
  /// @hide
  bool isPolling() {
    return !_quitting;
  }

  Future<Message?> next() async {
    return await _next(false);
  }

  Future<Message?> nextAsync() async {
    return await _next(true);
  }

  FutureOr<Message?> _next(bool async) async {
    int pendingIdleHandlerCount = -1; // -1 only during first iteration.
    int nextPollTimeoutMillis = 0;

    /// Poll the message queue until a message is available.
    ///
    /// When quitting, the loop will return null regardless of the state of the queue.
    /// When got a message, the loop will return message immediately.
    /// When continuing, the loop will return true.
    Future<Object?> nextMessage() async {
      await pollOnce(nextPollTimeoutMillis);

      // Try to retrieve the next message.  Return if found.
      final now = DateTime.now().microsecondsSinceEpoch;
      Message? prevMsg;
      Message? msg = _messages;

      // msg != null && msg.target == null
      if (msg != null && msg.isBarrier(Message.kBarrierSync)) {
        // Stalled by a barrier.  Find the next asynchronous message in the queue.
        do {
          prevMsg = msg;
          msg = msg?.next;
          // msg != null && !msg.isAsynchronous()
        } while (msg != null && (msg.isBarrier() || !msg.isAsynchronous()));
      }

      // Supports cleanup barrier
      if (msg != null && msg.isBarrier()) {
        do {
          prevMsg = msg;
          msg = msg?.next;
        } while (msg != null && msg.isBarrier());
      }

      if (msg != null) {
        if (now < msg.when) {
          // Next message is not ready. Set a timeout to wake up when it is ready.
          nextPollTimeoutMillis = min(msg.when - now, 0xFFFFFFFF);
        } else {
          // Got a message.
          _blocked = false;
          if (prevMsg != null) {
            prevMsg.next = msg.next;
          } else {
            _messages = msg.next;
          }
          msg.next = null;
          if (_kDebug) print('$_kTag: Returning message $msg');
          msg.markInUse();
          return msg;
        }
      } else {
        // No more messages.
        nextPollTimeoutMillis = -1;
      }

      // Process the quit message now that all pending messages have been handled.
      if (_quitting) {
        _dispose();
        return null;
      }

      // If first time idle, then get the number of idlers to run.
      // Idle handles only run if the queue is empty or if the first message
      // in the queue (possible a barrier) is due to be handled in the future.
      if (pendingIdleHandlerCount < 0 &&
          (_messages == null || now < _messages!.when)) {
        pendingIdleHandlerCount = _idleHandlers.length;
      }
      if (pendingIdleHandlerCount <= 0) {
        // No idle handler to run. Loop and wait some more.
        _blocked = true;
        return true; // continue
      }

      _pendingIdleHandlers ??=
          List.filled(max(pendingIdleHandlerCount, 4), null);
      // for (int i = 0; i < _idleHandlers.length; i++) {
      //   _pendingIdleHandlers![i] = _idleHandlers[i];
      // }
      _pendingIdleHandlers!.setRange(0, _idleHandlers.length, _idleHandlers);

      // Run the idle handlers.
      // We only ever reach this code block during the first iteration.
      for (int i = 0; i < pendingIdleHandlerCount; i++) {
        final idler = _pendingIdleHandlers![i];
        _pendingIdleHandlers![i] = null; // release the reference to the handler

        bool keep = false;
        try {
          keep = idler!();
        } catch (e) {
          print('$_kTag: Exception in idle handler.');
          print(e);
        }

        if (!keep) {
          _idleHandlers.remove(idler);
        }
      }

      // Reset the idle handler count to 0, so we do not run them again.
      pendingIdleHandlerCount = 0;

      // While calling an idle handler, a new message could have been delivered
      // so go back and lock again for a pending message without waiting.
      nextPollTimeoutMillis = 0;
      return true; // continue
    }

    if (!async) {
      while (true) {
        final msg = await nextMessage();
        if (msg == true) continue;
        return msg as Message?;
      }
    } else {
      Completer<Message?> ret = Completer();
      Future.doWhile(() async {
        final msg = await nextMessage();
        if (msg == true) return true;
        ret.complete(msg as Message?);
        return false;
      });
      return ret.future;
    }
  }

  void quit(bool safe) {
    if (!_quitAllowed) {
      throw Exception(
          'Cannot quit() a Looper that was not created with quitAllowed=true');
    }

    if (_quitting) return;
    _quitting = true;

    if (safe) {
      removeAllFutureMessagesLocked();
    } else {
      removeAllMessagesLocked();
    }

    // We can assume mPtr != 0 because mQuitting was previously false.
    _wake();
  }

  /// Posts a synchronization barrier to the Looper's message queue.
  ///
  /// Message processing occurs as usual until the message queue encounters the
  /// synchronization barrier that has been posted.  When the barrier is encountered,
  /// later synchronous messages in the queue are stalled (prevented from being executed)
  /// until the barrier is released by calling {@link #removeSyncBarrier} and specifying
  /// the token that identifies the synchronization barrier.
  ///
  /// This method is used to immediately postpone execution of all subsequently posted
  /// synchronous messages until a condition is met that releases the barrier.
  /// Asynchronous messages (see {@link Message#isAsynchronous} are exempt from the barrier
  /// and continue to be processed as usual.
  ///
  /// This call must be always matched by a call to {@link #removeSyncBarrier} with
  /// the same token to ensure that the message queue resumes normal operation.
  /// Otherwise the application will probably hang!
  ///
  /// @return A token that uniquely identifies the barrier.  This token must be
  /// passed to {@link #removeSyncBarrier} to release the barrier.
  ///
  /// @hide
  int postSyncBarrier() {
    return _postSyncBarrierWith(DateTime.now().microsecondsSinceEpoch);
  }

  int _postSyncBarrierWith(int when) {
    return _postBarrierWith(Message.kBarrierSync, when);
  }

  int postCleanupBarrier() {
    return _postCleanupBarrierWith(DateTime.now().microsecondsSinceEpoch);
  }

  int _postCleanupBarrierWith(int when) {
    return _postBarrierWith(Message.kBarrierCleanup, when);
  }

  int _postBarrierWith(int barrierType, int when) {
    // Enqueue a new sync barrier token.
    // We don't need to wake the queue because we the purpose of a barrier is to stall it.
    final token = _nextBarrierToken++;
    final msg = Message.obtain();
    msg.markInUse();
    msg.markBarrier(barrierType);
    msg.when = when;
    msg.arg1 = token;

    Message? prev;
    Message? p = _messages;
    if (when != 0) {
      while (p != null && p.when <= when) {
        prev = p;
        p = p.next;
      }
    }
    if (prev != null) {
      // invariant: p == prev.nex
      msg.next = p;
      prev.next = msg;
    } else {
      msg.next = p;
      _messages = msg;
    }
    return token;
  }

  /// Removes a synchronization barrier.
  ///
  /// @param token The synchronization barrier token that was returned by
  /// [postSyncBarrier].
  ///
  /// @throws IllegalStateException if the barrier was not found.
  ///
  /// @hide
  void removeSyncBarrier(int token) {
    _removeBarrier(Message.kBarrierSync, token);
  }

  void removeCleanupBarrier(int token) {
    _removeBarrier(Message.kBarrierCleanup, token);
  }

  void _removeBarrier(int? barrierType, int token) {
    // Remove a sync barrier token from the queue.
    // If the queue is no longer stalled by a barrier then wake it.
    Message? prev;
    Message? p = _messages;
    // p != null && (p.target != null || p.arg1 != token)
    while (p != null && (!p.isBarrier(barrierType) || p.arg1 != token)) {
      prev = p;
      p = p.next;
    }
    if (p == null) {
      throw Exception("The specified message queue synchronization '"
          "'barrier token has not been posted or is already removed.");
    }
    final bool needWake;
    if (prev != null) {
      prev.next = p.next;
      needWake = false;
    } else {
      _messages = p.next;
      // needWake = _messages == null || _message.target != null.
      needWake = _messages == null || !_messages!.isBarrier(barrierType);
    }
    p.recycleUnchecked();

    // If the loop is quitting then it is already awake.
    if (needWake && !_quitting) {
      _wake();
    }
  }

  bool enqueueMessage(Message msg, int when) {
    if (msg.target == null) {
      throw Exception("Message must have a target.");
    }

    if (msg.isBarrier()) {
      throw Exception('Cannot enqueue messages while inside a barrier');
    }

    if (msg.isInUse()) {
      throw Exception('$msg This message is already in use.');
    }

    if (_quitting) {
      print('$msg This message cannot be '
          'enqueued while the looper is quitting.');
      msg.recycle();
      return false;
    }

    msg.markInUse();
    msg.when = when;
    Message? p = _messages;
    bool needWake;
    if (p == null || when == 0 || when < p.when) {
      // New head, wake up the event queue if blocked.
      msg.next = p;
      _messages = msg;
      needWake = _blocked;
    } else {
      // Inserted within the middle of the queue. Usually we don't have to wake
      // up the event queue unless there is a barrier at the head of the queue
      // and the message is the earliest asynchronous message in the queue.
      needWake =
          _blocked && p.isBarrier(Message.kBarrierSync) && msg.isAsynchronous();
      Message? prev;
      while (true) {
        prev = p;
        p = p?.next;
        if (p == null || when < p.when) {
          break;
        }
        if (needWake && p.isAsynchronous()) {
          needWake = false;
        }
      }
      msg.next = p; // invariant: p == prev.next
      prev?.next = msg;
    }

    // We can assume mPtr != 0 because mQuitting is false.
    if (needWake) _wake();

    return true;
  }

  bool hasMessages(Handler? h, int what, Object? object) {
    if (h == null) return false;

    Message? p = _messages;
    while (p != null) {
      if (p.target == h &&
          p.what == what &&
          (object == null || p.obj == object)) {
        return true;
      }
      p = p.next;
    }
    return false;
  }

  bool hasMessages2(Handler? h, Runnable? r, Object? object) {
    if (h == null) return false;

    Message? p = _messages;
    while (p != null) {
      if (p.target == h &&
          p.callback == r &&
          (object == null || p.obj == object)) {
        return true;
      }
      p = p.next;
    }
    return false;
  }

  bool hasMessages3(Handler? h) {
    if (h == null) return false;

    Message? p = _messages;
    while (p != null) {
      if (p.target == h) {
        return true;
      }
      p = p.next;
    }
    return false;
  }

  void removeMessages(Handler? h, int what, Object? object) {
    if (h == null) return;

    Message? p = _messages;
    // Remove all messages at front.
    while (p != null &&
        p.target == h &&
        p.what == what &&
        (object == null || p.obj == object)) {
      Message? n = p.next;
      _messages = n;
      p.recycleUnchecked();
      p = n;
    }

    // Remove all messages after front.
    while (p != null) {
      Message? n = p.next;
      if (n != null) {
        if (n.target == h &&
            n.what == what &&
            (object == null || n.obj == object)) {
          Message? nn = n.next;
          n.recycleUnchecked();
          p.next = nn;
          continue;
        }
      }
      p = n;
    }
  }

  void removeMessages2(Handler? h, Runnable? r, Object? object) {
    if (h == null || r == null) {
      return;
    }

    Message? p = _messages;

    // Remove all messages at front.
    while (p != null &&
        p.target == h &&
        p.callback == r &&
        (object == null || p.obj == object)) {
      Message? n = p.next;
      _messages = n;
      p.recycleUnchecked();
      p = n;
    }

    // Remove all messages after front.
    while (p != null) {
      Message? n = p.next;
      if (n != null) {
        if (n.target == h &&
            n.callback == r &&
            (object == null || n.obj == object)) {
          Message? nn = n.next;
          n.recycleUnchecked();
          p.next = nn;
          continue;
        }
      }
      p = n;
    }
  }

  void removeCallbacksAndMessages(Handler? h, Object? object) {
    if (h == null) {
      return;
    }

    Message? p = _messages;

    // Remove all messages at front.
    while (p != null && p.target == h && (object == null || p.obj == object)) {
      Message? n = p.next;
      _messages = n;
      p.recycleUnchecked();
      p = n;
    }

    // Remove all messages after front.
    while (p != null) {
      Message? n = p.next;
      if (n != null) {
        if (n.target == h && (object == null || n.obj == object)) {
          Message? nn = n.next;
          n.recycleUnchecked();
          p.next = nn;
          continue;
        }
      }
      p = n;
    }
  }

  void removeAllMessagesLocked() {
    Message? p = _messages;
    while (p != null) {
      Message? n = p.next;
      p.recycleUnchecked();
      p = n;
    }
    _messages = null;
  }

  void removeAllFutureMessagesLocked() {
    final now = DateTime.now().microsecondsSinceEpoch;
    Message? p = _messages;
    if (p != null) {
      if (p.when > now) {
        removeAllMessagesLocked();
      } else {
        Message? n;
        for (;;) {
          n = p?.next;
          if (n == null) return;
          if (n.when > now) break;
          p = n;
        }
        p?.next = null;
        do {
          p = n;
          n = p?.next;
          p?.recycleUnchecked();
        } while (n != null);
      }
    }
  }

  Future<void> pollOnce(int timeoutMillis) async {
    if (_blocked) {
      _pollLocker ??= Completer();
      var lockerFuture = _pollLocker!.future;
      if (timeoutMillis >= 0) {
        lockerFuture =
            lockerFuture.timeout(Duration(milliseconds: timeoutMillis));
      }
      await lockerFuture;
    }
  }

  void _wake() {
    _pollLocker?.complete();
    _pollLocker = null;
  }
}

/// Callback interface for discovering when a thread is going to block
/// waiting for more messages.
///
/// Called when the message queue has run out of messages and will now
/// wait for more.  Return true to keep your idle handler active, false
/// to have it removed.  This may be called if there are still messages
/// pending in the queue, but they are all scheduled to be dispatched
/// after the current time.
typedef IdleHandler = bool Function();
