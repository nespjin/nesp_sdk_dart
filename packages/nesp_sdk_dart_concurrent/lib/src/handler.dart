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
import 'looper.dart';
import 'message.dart';
import 'message_queue.dart';
import 'runnable.dart';

///
/// Ported from AOSP Project ```frameworks/base/core/java/android/os/Handler.java```
///

/// Callback interface you can use when instantiating a Handler to avoid
/// having to implement your own subclass of Handler.
///
/// [msg] A {@link android.os.Message Message} object
/// @return True if no further handling is desired
typedef HandlerCallback = Future<bool> Function(Message msg);

/// A Handler allows you to send and process {@link Message} and Runnable
/// objects associated with a thread's {@link MessageQueue}.  Each Handler
/// instance is associated with a single thread and that thread's message
/// queue.  When you create a new Handler, it is bound to the thread /
/// message queue of the thread that is creating it -- from that point on,
/// it will deliver messages and runnables to that message queue and execute
/// them as they come out of the message queue.
///
/// <p>There are two main uses for a Handler: (1) to schedule messages and
/// runnables to be executed as some point in the future; and (2) to enqueue
/// an action to be performed on a different thread than your own.
///
/// <p>Scheduling messages is accomplished with the
/// {@link #post}, {@link #postAtTime(Runnable, long)},
/// {@link #postDelayed}, {@link #sendEmptyMessage},
/// {@link #sendMessage}, {@link #sendMessageAtTime}, and
/// {@link #sendMessageDelayed} methods.  The <em>post</em> versions allow
/// you to enqueue Runnable objects to be called by the message queue when
/// they are received; the <em>sendMessage</em> versions allow you to enqueue
/// a {@link Message} object containing a bundle of data that will be
/// processed by the Handler's {@link #handleMessage} method (requiring that
/// you implement a subclass of Handler).
///
/// <p>When posting or sending to a Handler, you can either
/// allow the item to be processed as soon as the message queue is ready
/// to do so, or specify a delay before it gets processed or absolute time for
/// it to be processed.  The latter two allow you to implement timeouts,
/// ticks, and other timing-based behavior.
///
/// <p>When a
/// process is created for your application, its main thread is dedicated to
/// running a message queue that takes care of managing the top-level
/// application objects (activities, broadcast receivers, etc) and any windows
/// they create.  You can create your own threads, and communicate back with
/// the main application thread through a Handler.  This is done by calling
/// the same <em>post</em> or <em>sendMessage</em> methods as before, but from
/// your new thread.  The given Runnable or Message will then be scheduled
/// in the Handler's message queue and processed when appropriate.
class Handler {
  static const String _kTag = 'Handler';

  /// Subclasses must implement this to receive messages.
  Future<void> handleMessage(Message msg) async {}

  /// Handle system messages here.
  Future<void> dispatchMessage(Message msg) async {
    if (msg.callback != null) {
      await _handleCallback(msg);
    } else {
      if (_callback != null) {
        if (await _callback!(msg)) {
          return;
        }
      }
      await handleMessage(msg);
    }
  }

  /// Use the provided {@link Looper} instead of the default one and take a callback
  /// interface in which to handle messages.  Also set whether the handler
  /// should be asynchronous.
  ///
  /// Handlers are synchronous by default unless this constructor is used to make
  /// one that is strictly asynchronous.
  ///
  /// Asynchronous messages represent interrupts or events that do not require global ordering
  /// with respect to synchronous messages.  Asynchronous messages are not subject to
  /// the synchronization barriers introduced by conditions such as display vsync.
  ///
  /// @param looper The looper, must not be null.
  /// @param callback The callback interface in which to handle messages, or null.
  /// @param async If true, the handler calls {@link Message#setAsynchronous(boolean)} for
  /// each {@link Message} that is sent to it or {@link Runnable} that is posted to it.
  ///
  /// @hide
  Handler(Looper looper, {HandlerCallback? callback, bool async = false}) {
    _looper = looper;
    _queue = looper.getQueue();
    _callback = callback;
    _asynchronous = async;
  }

  /// Create a new Handler whose posted messages and runnables are not subject to
  /// synchronization barriers such as display vsync.
  ///
  /// <p>Messages sent to an async handler are guaranteed to be ordered with respect to one another,
  /// but not necessarily with respect to messages from other Handlers.</p>
  ///
  /// @see #createAsync(Looper) to create an async Handler without custom message handling.
  ///
  /// @param looper the Looper that the new Handler should be bound to
  /// @return a new async Handler instance
  static Handler createAsync(Looper looper, {HandlerCallback? callback}) {
    return Handler(looper, callback: callback, async: true);
  }

  String getTraceName(Message message) {
    final StringBuffer sb = StringBuffer();
    sb.write(runtimeType.toString());
    sb.write(": ");
    if (message.callback != null) {
      sb.write(message.callback.runtimeType.toString());
    } else {
      sb.write("#");
      sb.write(message.what);
    }
    return sb.toString();
  }

  /// Returns a string representing the name of the specified message.
  /// The default implementation will either return the class name of the
  /// message callback if any, or the hexadecimal representation of the
  /// message "what" field.
  ///
  /// @param message The message whose name is being queried
  String setMessageName(Message message) {
    if (message.callback != null) {
      return message.callback!.runtimeType.toString();
    }
    return '0x${message.what.toRadixString(16)}';
  }

  /// Returns a new {@link android.os.Message Message} from the global message pool. More efficient than
  /// creating and allocating new instances. The retrieved message has its handler set to this instance (Message.target == this).
  ///  If you don't want that facility, just call Message.obtain() instead.
  /// [what] Value to assign to the returned Message.what field.
  /// [arg1] Value to assign to the returned Message.arg1 field.
  /// [arg2] Value to assign to the returned Message.arg2 field
  ///  [obj] Value to assign to the returned Message.obj field.
  Message obtainMessage({
    int? what,
    int? arg1,
    int? arg2,
    Runnable? callback,
    Object? obj,
  }) {
    return Message.obtainWith(
      h: this,
      what: what,
      arg1: arg1,
      arg2: arg2,
      callback: callback,
      obj: obj,
    );
  }

  /// Causes the Runnable r to be added to the message queue.
  /// The runnable will be run on the thread to which this handler is
  /// attached.
  ///
  /// @param r The Runnable that will be executed.
  ///
  /// @return Returns true if the Runnable was successfully placed in to the
  ///         message queue.  Returns false on failure, usually because the
  ///         looper processing the message queue is exiting.
  bool post(Runnable r) {
    return sendMessageDelayed(_getPostMessage(r), 0);
  }

  /// Causes the Runnable r to be added to the message queue, to be run
  /// at a specific time given by <var>uptimeMillis</var>.
  /// <b>The time-base is {@link android.os.SystemClock#uptimeMillis}.</b>
  /// Time spent in deep sleep will add an additional delay to execution.
  /// The runnable will be run on the thread to which this handler is attached.
  ///
  /// @param r The Runnable that will be executed.
  /// @param token An instance which can be used to cancel {@code r} via
  ///         {@link #removeCallbacksAndMessages}.
  /// @param uptimeMillis The absolute time at which the callback should run,
  ///         using the {@link android.os.SystemClock#uptimeMillis} time-base.
  ///
  /// @return Returns true if the Runnable was successfully placed in to the
  ///         message queue.  Returns false on failure, usually because the
  ///         looper processing the message queue is exiting.  Note that a
  ///         result of true does not mean the Runnable will be processed -- if
  ///         the looper is quit before the delivery time of the message
  ///         occurs then the message will be dropped.
  ///
  /// @see android.os.SystemClock#uptimeMillis
  bool postAtTime(Runnable r, int uptimeMillis, {Object? token}) {
    return sendMessageAtTime(_getPostMessage(r, token: token), uptimeMillis);
  }

  /// Causes the Runnable r to be added to the message queue, to be run
  /// after the specified amount of time elapses.
  /// The runnable will be run on the thread to which this handler
  /// is attached.
  /// <b>The time-base is {@link android.os.SystemClock#uptimeMillis}.</b>
  /// Time spent in deep sleep will add an additional delay to execution.
  ///
  /// @param r The Runnable that will be executed.
  /// @param token An instance which can be used to cancel {@code r} via
  ///         {@link #removeCallbacksAndMessages}.
  /// @param delayMillis The delay (in milliseconds) until the Runnable
  ///        will be executed.
  ///
  /// @return Returns true if the Runnable was successfully placed in to the
  ///         message queue.  Returns false on failure, usually because the
  ///         looper processing the message queue is exiting.  Note that a
  ///         result of true does not mean the Runnable will be processed --
  ///         if the looper is quit before the delivery time of the message
  ///         occurs then the message will be dropped.
  bool postDelayed(Runnable r, int delayMillis, {Object? token}) {
    return sendMessageDelayed(_getPostMessage(r, token: token), delayMillis);
  }

  /// Posts a message to an object that implements Runnable.
  /// Causes the Runnable r to executed on the next iteration through the
  /// message queue. The runnable will be run on the thread to which this
  /// handler is attached.
  /// <b>This method is only for use in very special circumstances -- it
  /// can easily starve the message queue, cause ordering problems, or have
  /// other unexpected side-effects.</b>
  ///
  /// @param r The Runnable that will be executed.
  ///
  /// @return Returns true if the message was successfully placed in to the
  ///         message queue.  Returns false on failure, usually because the
  ///         looper processing the message queue is exiting.
  bool postAtFrontOfQueue(Runnable r) {
    return sendMessageAtFrontOfQueue(_getPostMessage(r));
  }

  /// Remove any pending posts of Runnable <var>r</var> with Object
  /// <var>token</var> that are in the message queue.  If <var>token</var> is null,
  /// all callbacks will be removed.
  void removeCallbacks(Runnable? r, {Object? token}) {
    _queue.removeMessages2(this, r, token);
  }

  /// Pushes a message onto the end of the message queue after all pending messages
  /// before the current time. It will be received in {@link #handleMessage},
  /// in the thread attached to this handler.
  ///
  /// @return Returns true if the message was successfully placed in to the
  ///         message queue.  Returns false on failure, usually because the
  ///         looper processing the message queue is exiting.
  bool sendMessage(Message msg) {
    return sendMessageDelayed(msg, 0);
  }

  /// Sends a Message containing only the what value.
  ///
  /// @return Returns true if the message was successfully placed in to the
  ///         message queue.  Returns false on failure, usually because the
  ///         looper processing the message queue is exiting.
  bool sendEmptyMessage(int what) {
    return sendEmptyMessageDelayed(what, 0);
  }

  /// Sends a Message containing only the what value, to be delivered
  /// after the specified amount of time elapses.
  /// @see #sendMessageDelayed(android.os.Message, long)
  ///
  /// @return Returns true if the message was successfully placed in to the
  ///         message queue.  Returns false on failure, usually because the
  ///         looper processing the message queue is exiting.
  bool sendEmptyMessageDelayed(int what, int delayMillis) {
    Message msg = Message.obtain();
    msg.what = what;
    return sendMessageDelayed(msg, delayMillis);
  }

  /// Sends a Message containing only the what value, to be delivered
  /// at a specific time.
  /// @see #sendMessageAtTime(android.os.Message, long)
  ///
  /// @return Returns true if the message was successfully placed in to the
  ///         message queue.  Returns false on failure, usually because the
  ///         looper processing the message queue is exiting.
  bool sendEmptyMessageAtTime(int what, int uptimeMillis) {
    Message msg = Message.obtain();
    msg.what = what;
    return sendMessageAtTime(msg, uptimeMillis);
  }

  /// Enqueue a message into the message queue after all pending messages
  /// before (current time + delayMillis). You will receive it in
  /// {@link #handleMessage}, in the thread attached to this handler.
  ///
  /// @return Returns true if the message was successfully placed in to the
  ///         message queue.  Returns false on failure, usually because the
  ///         looper processing the message queue is exiting.  Note that a
  ///         result of true does not mean the message will be processed -- if
  ///         the looper is quit before the delivery time of the message
  ///         occurs then the message will be dropped.
  bool sendMessageDelayed(Message msg, int delayMillis) {
    if (delayMillis < 0) {
      delayMillis = 0;
    }
    final now = DateTime.now().microsecondsSinceEpoch;
    return sendMessageAtTime(msg, now + delayMillis);
  }

  /// Enqueue a message into the message queue after all pending messages
  /// before the absolute time (in milliseconds) <var>uptimeMillis</var>.
  /// <b>The time-base is {@link android.os.SystemClock#uptimeMillis}.</b>
  /// Time spent in deep sleep will add an additional delay to execution.
  /// You will receive it in {@link #handleMessage}, in the thread attached
  /// to this handler.
  ///
  /// @param uptimeMillis The absolute time at which the message should be
  ///         delivered, using the
  ///         {@link android.os.SystemClock#uptimeMillis} time-base.
  ///
  /// @return Returns true if the message was successfully placed in to the
  ///         message queue.  Returns false on failure, usually because the
  ///         looper processing the message queue is exiting.  Note that a
  ///         result of true does not mean the message will be processed -- if
  ///         the looper is quit before the delivery time of the message
  ///         occurs then the message will be dropped.
  bool sendMessageAtTime(Message msg, int uptimeMillis) {
    MessageQueue queue = _queue;
    return _enqueueMessage(queue, msg, uptimeMillis);
  }

  /// Enqueue a message at the front of the message queue, to be processed on
  /// the next iteration of the message loop.  You will receive it in
  /// {@link #handleMessage}, in the thread attached to this handler.
  /// <b>This method is only for use in very special circumstances -- it
  /// can easily starve the message queue, cause ordering problems, or have
  /// other unexpected side-effects.</b>
  ///
  /// @return Returns true if the message was successfully placed in to the
  ///         message queue.  Returns false on failure, usually because the
  ///         looper processing the message queue is exiting.
  bool sendMessageAtFrontOfQueue(Message msg) {
    MessageQueue queue = _queue;
    return _enqueueMessage(queue, msg, 0);
  }

  /// Executes the message synchronously if called on the same thread this handler corresponds to,
  /// or {@link #sendMessage pushes it to the queue} otherwise
  ///
  /// @return Returns true if the message was successfully ran or placed in to the
  ///         message queue.  Returns false on failure, usually because the
  ///         looper processing the message queue is exiting.
  /// @hide
  bool executeOrSendMessage(Message msg) {
    if (_looper == Looper.myLooper()) {
      dispatchMessage(msg);
      return true;
    }
    return sendMessage(msg);
  }

  bool _enqueueMessage(MessageQueue queue, Message msg, int uptimeMillis) {
    msg.target = this;
    if (_asynchronous) {
      msg.setAsynchronous(true);
    }
    return queue.enqueueMessage(msg, uptimeMillis);
  }

  /// Remove any pending posts of messages with code 'what' and whose obj is
  /// 'object' that are in the message queue.  If <var>object</var> is null,
  /// all messages will be removed.
  void removeMessages(int what, {Object? object}) {
    _queue.removeMessages(this, what, object);
  }

  /// Remove any pending posts of callbacks and sent messages whose
  /// <var>obj</var> is <var>token</var>.  If <var>token</var> is null,
  /// all callbacks and messages will be removed.
  void removeCallbacksAndMessages(Object? token) {
    _queue.removeCallbacksAndMessages(this, token);
  }

  /// Return whether there are any messages or callbacks currently scheduled on this handler.
  bool hasMessagesOrCallbacks() {
    return _queue.hasMessages3(this);
  }

  /// Check if there are any pending posts of messages with code 'what' and
  /// whose obj is 'object' in the message queue.
  ///
  /// If [object] is null, check if there are any pending posts of messages with code 'what' in
  /// the message queue.
  bool hasMessages(int what, {Object? object}) {
    return _queue.hasMessages(this, what, object);
  }

  /// Check if there are any pending posts of messages with callback r in
  /// the message queue.
  bool hasCallbacks(Runnable r) {
    return _queue.hasMessages2(this, r, null);
  }

  // if we can get rid of this method, the handler need not remember its loop
  // we could instead export a getMessageQueue() method...
  Looper getLooper() {
    return _looper;
  }

  @override
  String toString() {
    return "Handler ($runtimeType) {${identityHashCode(this).toRadixString(16)}}";
  }

  static Message _getPostMessage(Runnable r, {Object? token}) {
    Message m = Message.obtain();
    m.callback = r;
    if (token != null) {
      m.obj = token;
    }
    return m;
  }

  static Future<void> _handleCallback(Message message) async {
    await message.callback!();
  }

  late final Looper _looper;
  late final MessageQueue _queue;
  HandlerCallback? _callback;
  late bool _asynchronous;
}
