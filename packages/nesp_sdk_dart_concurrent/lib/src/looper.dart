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
import 'dart:isolate';

import 'message.dart';
import 'message_queue.dart';

///
/// Ported from AOSP Project ```frameworks/base/core/java/android/os/Looper.java```
///

/// Class used to run a message loop for a thread.  Threads by default do
/// not have a message loop associated with them; to create one, call
/// {@link #prepare} in the thread that is to run the loop, and then
/// {@link #loop} to have it process messages until the loop is stopped.
///
/// <p>Most interaction with a message loop is through the
/// {@link Handler} class.
///
/// <p>This is a typical example of the implementation of a Looper thread,
/// using the separation of {@link #prepare} and {@link #loop} to create an
/// initial Handler to communicate with the Looper.
///
/// <pre>
///  class LooperThread extends Thread {
///      public Handler mHandler;
///
///      public void run() {
///          Looper.prepare();
///
///          mHandler = new Handler() {
///              public void handleMessage(Message msg) {
///                  // process incoming messages here
///              }
///          };
///
///          Looper.loop();
///      }
///  }</pre>
class Looper {
  /*
  * API Implementation Note:
  *
  * This class contains the code required to set up and manage an event loop
  * based on MessageQueue.  APIs that affect the state of the queue should be
  * defined on MessageQueue or Handler rather than on Looper itself.  For example,
  * idle handlers and sync barriers are defined on the queue whereas preparing the
  * thread, looping, and quitting are defined on the looper.
  */

  static const String _kTag = 'Looper';

  /// The looper of current isolate.
  static Looper? _currentLooper;

  late MessageQueue _queue;
  late final Isolate _isolate;

  /// The looper is
  late final bool _isInSameIsolate;

  /// If set, the looper will show a warning log if a message dispatch takes longer than this.
  int _slowDispatchThresholdMs = 0;

  /// If set, the looper will show a warning log if a message delivery (actual delivery time -
  /// post time) takes longer than this.
  int _slowDeliveryThresholdMs = 0;

  /// Initialize the current thread as a looper.
  /// This gives you a chance to create handlers that then reference
  /// this looper, before actually starting the loop. Be sure to call
  /// [loop] after calling this method, and end it by calling
  /// [quit].
  static void prepare({bool isInSameIsolate = true}) {
    assert(isInSameIsolate,
        'Looper.prepare() must be called in the same isolate.');
    _prepare(true, isInSameIsolate);
  }

  static void _prepare(bool quitAllowed, bool isInSameIsolate) {
    if (_currentLooper != null) {
      throw Exception("Only one Looper may be created per isolate");
    }
    _currentLooper = Looper(
      quitAllowed: quitAllowed,
      isInSameIsolate: isInSameIsolate,
    );
  }

  /// Run the message queue in this thread. Be sure to call
  /// {@link #quit()} to end the loop.
  static void loop([Looper? looper]) async {
    final Looper? me = looper ?? myLooper();
    if (me == null) {
      throw Exception(
          "No Looper; Looper.prepare() wasn't called on this thread.");
    }
    final queue = me._queue;
    final isInSameIsolate = me._isInSameIsolate;

    bool slowDeliveryDetected = false;

    Future<bool> loopOnce(Message msg) async {
      int slowDispatchThresholdMs = me._slowDispatchThresholdMs;
      int slowDeliveryThresholdMs = me._slowDeliveryThresholdMs;

      final logSlowDelivery = (slowDeliveryThresholdMs > 0) && (msg.when > 0);
      final logSlowDispatch = (slowDispatchThresholdMs > 0);

      final needStartTime = logSlowDelivery || logSlowDispatch;
      final needEndTime = logSlowDispatch;

      var now = DateTime.now();
      final dispatchStart = needStartTime ? now.millisecondsSinceEpoch : 0;
      late final int dispatchEnd;

      try {
        await msg.target!.dispatchMessage(msg);
        now = DateTime.now();
        dispatchEnd = needEndTime ? now.millisecondsSinceEpoch : 0;
      } finally {}

      if (logSlowDelivery) {
        if (slowDeliveryDetected) {
          if ((dispatchStart - msg.when) <= 10) {
            slowDeliveryDetected = false;
          }
        } else {
          if (_showSlowLog(slowDeliveryThresholdMs, msg.when, dispatchStart,
              'delivery', msg)) {
            // Once we write a slow delivery log, suppress until the queue drains.
            slowDeliveryDetected = true;
          }
        }
      }

      if (logSlowDispatch) {
        _showSlowLog(slowDispatchThresholdMs, dispatchStart, dispatchEnd,
            'dispatch', msg);
      }

      msg.recycleUnchecked();
      return true;
    }

    if (isInSameIsolate) {
      Future.doWhile(() async {
        Message? msg = await queue.nextAsync(); // might block
        if (msg == null) {
          // No message indicates that the message queue is quitting.
          return false;
        }
        return loopOnce(msg);
      });
    } else {
      while (true) {
        Message? msg = await queue.next(); // might block
        if (msg == null) {
          // No message indicates that the message queue is quitting.
          return;
        }
        if (!await loopOnce(msg)) break;
      }
    }
  }

  static bool _showSlowLog(int threshold, int measureStart, int measureEnd,
      String what, Message msg) {
    final int actualTime = measureEnd - measureStart;
    if (actualTime < threshold) return false;
    // For slow delivery, the current message isn't really important, but log it anyway.
    print('$_kTag Slow $what took ${actualTime}ms, ${Isolate.current.hashCode}'
        ' h=${msg.target?.runtimeType} c=${msg.callback} m=${msg.what}');
    return true;
  }

  /// Return the Looper object associated with the current isolate.  Returns
  /// null if the calling thread is not associated with a Looper.
  static Looper? myLooper() {
    return _currentLooper;
  }

  /// Return the [MessageQueue] object associated with the current
  /// isolate.  This must be called from a isolate running a Looper, or a
  /// NullPointerException will be thrown.
  static MessageQueue myQueue() {
    return myLooper()!._queue;
  }

  MessageQueue get queue => _queue;

  Looper({bool quitAllowed = true, bool isInSameIsolate = true}) {
    _queue = MessageQueue(quitAllowed);
    _isolate = Isolate.current;
    _isInSameIsolate = isInSameIsolate;
  }

  /// Returns true if the current thread is this looper's isolate.
  bool isCurrentIsolate() {
    return Isolate.current == _isolate;
  }

  /// Set a thresholds for slow dispatch/delivery log.
  void setSlowLogThresholdMs(
      int slowDispatchThresholdMs, int slowDeliveryThresholdMs) {
    _slowDispatchThresholdMs = slowDispatchThresholdMs;
    _slowDeliveryThresholdMs = slowDeliveryThresholdMs;
  }

  /// Quits the looper.
  /// <p>
  /// Causes the {@link #loop} method to terminate without processing any
  /// more messages in the message queue.
  /// </p><p>
  /// Any attempt to post messages to the queue after the looper is asked to quit will fail.
  /// For example, the {@link Handler#sendMessage(Message)} method will return false.
  /// </p><p class="note">
  /// Using this method may be unsafe because some messages may not be delivered
  /// before the looper terminates.  Consider using {@link #quitSafely} instead to ensure
  /// that all pending work is completed in an orderly manner.
  /// </p>
  ///
  /// @see #quitSafely
  void quit() {
    _queue.quit(false);
  }

  /// Quits the looper safely.
  /// <p>
  /// Causes the {@link #loop} method to terminate as soon as all remaining messages
  /// in the message queue that are already due to be delivered have been handled.
  /// However pending delayed messages with due times in the future will not be
  /// delivered before the loop terminates.
  /// </p><p>
  /// Any attempt to post messages to the queue after the looper is asked to quit will fail.
  /// For example, the {@link Handler#sendMessage(Message)} method will return false.
  /// </p>
  void quitSafely() {
    _queue.quit(true);
  }

  /// Gets the Isolate associated with this Looper.
  ///
  /// @return The looper's Isolate.
  Isolate getIsolate() {
    return _isolate;
  }

  /// Gets this looper's message queue.
  ///
  /// @return The looper's message queue.
  MessageQueue getQueue() {
    return _queue;
  }

  /// Dumps the state of the looper for debugging purposes.
  ///
  /// @param pw A printer to receive the contents of the dump.
  /// @param prefix A prefix to prepend to each line which is printed.
  void dump(PrintHandler pw, String prefix) {
    // pw(Zone.current,null,prefix + toString());
    // _queue.dump( prefix + "  ", null);
  }

  @override
  String toString() {
    return 'Looper(${_isolate.debugName}, isolateId ${_isolate.hashCode})'
        '{${identityHashCode(this).toRadixString(16)}';
  }
}
