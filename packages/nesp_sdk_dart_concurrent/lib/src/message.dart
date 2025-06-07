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
import 'handler.dart';
import 'runnable.dart';
///
/// Ported from AOSP Project ```frameworks/base/core/java/android/os/Message.java```
///

/// Defines a message containing a description and arbitrary data object that can be
/// sent to a [Handler].  This object contains two extra int fields and an
/// extra object field that allow you to not do allocations in many cases.
///
/// <p class="note">While the constructor of Message is public, the best way to get
/// one of these is to call [obtain] or one of the
/// [Handler.obtainMessage] methods, which will pull
/// them from a pool of recycled objects.</p>
class Message {
  /// User-defined message code so that the recipient can identify
  /// what this message is about. Each [Handler] has its own name-space
  /// for message codes, so you do not need to worry about yours conflicting
  /// with other handlers.
  int what = 0;

  /// arg1 and arg2 are lower-cost alternatives to using
  /// {@link #setData(Bundle) setData()} if you only need to store a
  /// few integer values.
  int arg1 = 0;

  /// arg1 and arg2 are lower-cost alternatives to using
  /// {@link #setData(Bundle) setData()} if you only need to store a
  /// few integer values.
  int arg2 = 0;

  /// An arbitrary object to send to the recipient.  When using
  /// {@link Messenger} to send the message across processes this can only
  /// be non-null if it contains a Parcelable of a framework class (not one
  /// implemented by the application).   For other data transfer use
  /// {@link #setData}.
  ///
  /// <p>Note that Parcelable objects here are not supported prior to
  /// the {@link android.os.Build.VERSION_CODES#FROYO} release.
  Object? obj;

  /// If set message is in use.
  /// This flag is set when the message is enqueued and remains set while it
  /// is delivered and afterwards when it is recycled.  The flag is only cleared
  /// when a new message is created or obtained since that is the only time that
  /// applications are allowed to modify the contents of the message.
  ///
  /// It is an error to attempt to enqueue or recycle a message that is already in use.
  static const int kFlagInUse = 1 << 0;

  /// If set message is asynchronous
  static const int kFlagAsynchronous = 1 << 1;

  /// Flags to clear in the copyFrom method
  static const int kFlagsToClearOnCopyFrom = kFlagInUse;

  static const int kBarrierSync = 0;
  static const int kBarrierCleanup = 1;

  int _barrierType = -1;

  int flags = 0;

  /// The targeted delivery time of this message, in milliseconds.
  int when = -1;

  /// Retrieve the a {@link android.os.Handler Handler} implementation that
  /// will receive this message. The object must implement
  /// {@link android.os.Handler#handleMessage(android.os.Message)
  /// Handler.handleMessage()}. Each Handler has its own name-space for
  /// message codes, so you do not need to
  /// worry about yours conflicting with other handlers.
  Handler? target;

  /// Retrieve callback object that will execute when this message is handled.
  /// This object must implement Runnable. This is called by
  /// the <em>target</em> {@link Handler} that is receiving this Message to
  /// dispatch it.  If
  /// not set, the message will be dispatched to the receiving Handler's
  /// {@link Handler#handleMessage(Message Handler.handleMessage())}.
  Runnable? callback;

  // sometimes we store linked lists of these things
  Message? next;

  static Message? _pool;
  static int _poolSize = 0;

  static const _kMaxPoolSize = 50;

  static bool _checkRecycle = true;

  /// Return a new Message instance from the global pool. Allows us to
  /// avoid allocating new objects in many cases.
  static Message obtain() {
    final pool = _pool;
    if (pool != null) {
      var m = pool;
      _pool = m.next;
      m.next = null;
      m.flags = 0;
      _poolSize--;
      return m;
    }
    return Message();
  }

  /// Same as [obtain], but copies the values of an existing
  /// message (including its target) into the new one.
  /// [orig] Original message to copy.
  /// [h] Handler to assign to the returned Message object's <em>target</em> member.
  /// [callback] Runnable that will execute when the message is handled.
  /// [obj]  The <em>object</em> method to set.
  /// returns A Message object from the global pool.
  static Message obtainWith({
    Message? orig,
    Handler? h,
    int? what,
    int? arg1,
    int? arg2,
    Runnable? callback,
    Object? obj,
  }) {
    var m = obtain();
    if (orig != null) {
      m.what = orig.what;
      m.arg1 = orig.arg1;
      m.arg2 = orig.arg2;
      m.obj = orig.obj;
      m.callback = orig.callback;
    }

    if (h != null) m.target = h;
    if (what != null) m.what = what;
    if (arg1 != null) m.arg1 = arg1;
    if (arg2 != null) m.arg2 = arg2;
    if (callback != null) m.callback = callback;
    if (obj != null) m.obj = obj;

    return m;
  }

  static void updateCheckRecycle() {
    _checkRecycle = false;
  }

  /// Return a Message instance to the global pool.
  ///
  /// You MUST NOT touch the Message after calling this function because it has
  /// effectively been freed.  It is an error to recycle a message that is currently
  /// enqueued or that is in the process of being delivered to a Handler.
  void recycle() {
    if (isInUse()) {
      if (_checkRecycle) {
        throw Exception('Message cannot be recycled while it is still in use.');
      }
      return;
    }
    recycleUnchecked();
  }

  /// Recycles a Message that may be in-use.
  /// Used internally by the MessageQueue and Looper when disposing of queued Messages.
  void recycleUnchecked() {
    // Mark the message as in use while it remains in the recycled object pool.
    // Clear out all other details.
    flags = kFlagInUse;
    what = 0;
    arg1 = 0;
    arg2 = 0;
    obj = null;
    when = 0;
    target = null;
    callback = null;

    if (_poolSize < _kMaxPoolSize) {
      next = _pool;
      _pool = this;
      _poolSize++;
    }
  }

  /// Make this message like o.  Performs a shallow copy of the data field.
  /// Does not copy the linked list fields, nor the timestamp or
  /// target/callback of the original message.
  void copyFrom(Message o) {
    flags = o.flags & ~kFlagsToClearOnCopyFrom;
    what = o.what;
    arg1 = o.arg1;
    arg2 = o.arg2;
    obj = o.obj;
  }

  /// Sends this Message to the Handler specified by {@link #getTarget}.
  /// Throws a null pointer exception if this field has not been set.
  void sendToTarget() {
    target!.sendMessage(this);
  }

  /// Returns true if the message is asynchronous, meaning that it is not
  /// subject to {@link Looper} synchronization barriers.
  ///
  /// @return True if the message is asynchronous.
  ///
  /// @see #setAsynchronous(boolean)
  bool isAsynchronous() {
    return (flags & kFlagAsynchronous) != 0;
  }

  /// Sets whether the message is asynchronous, meaning that it is not
  /// subject to {@link Looper} synchronization barriers.
  /// <p>
  /// Certain operations, such as view invalidation, may introduce synchronization
  /// barriers into the {@link Looper}'s message queue to prevent subsequent messages
  /// from being delivered until some condition is met.  In the case of view invalidation,
  /// messages which are posted after a call to {@link android.view.View#invalidate}
  /// are suspended by means of a synchronization barrier until the next frame is
  /// ready to be drawn.  The synchronization barrier ensures that the invalidation
  /// request is completely handled before resuming.
  /// </p><p>
  /// Asynchronous messages are exempt from synchronization barriers.  They typically
  /// represent interrupts, input events, and other signals that must be handled independently
  /// even while other work has been suspended.
  /// </p><p>
  /// Note that asynchronous messages may be delivered out of order with respect to
  /// synchronous messages although they are always delivered in order among themselves.
  /// If the relative order of these messages matters then they probably should not be
  /// asynchronous in the first place.  Use with caution.
  /// </p>
  ///
  /// @param async True if the message is asynchronous.
  ///
  /// @see #isAsynchronous()
  void setAsynchronous(bool async) {
    if (async) {
      flags |= kFlagAsynchronous;
    } else {
      flags &= ~kFlagAsynchronous;
    }
  }

  bool isInUse() {
    return (flags & kFlagInUse) == kFlagInUse;
  }

  void markInUse() {
    flags |= kFlagInUse;
  }

  bool isBarrier([int? barrierType]) {
    return barrierType == null ? _barrierType > 0 : _barrierType == barrierType;
  }

  void markBarrier(int barrierType) {
    if (target != null) {
      throw Exception('Cannot mark a message as a barrier '
          'when it has already been delivered.');
    }

    if (barrierType != kBarrierSync && barrierType != kBarrierCleanup) {
      throw Exception('The barrier type must be one of the following: '
          '$kBarrierSync, $kBarrierCleanup');
    }

    _barrierType = barrierType;
  }

  /// Constructor (but the preferred way to get a Message is to call {@link #obtain() Message.obtain()}).
  Message();

  @override
  String toString() {
    return toStringWith(DateTime.now().millisecondsSinceEpoch);
  }

  String toStringWith(int now) {
    final b = StringBuffer();
    b.write('{ when=${Duration(milliseconds: when - now)}');
    if (target != null) {
      if (callback != null) {
        b.write(' callback=${callback!.runtimeType}');
      } else {
        b.write(' what=$what');
      }

      if (arg1 != 0) {
        b.write(' arg1=$arg1');
      }

      if (arg2 != 0) {
        b.write(' arg2=$arg2');
      }

      if (obj != null) {
        b.write(' obj=$obj');
      }

      b.write(' target=${target!.runtimeType}');
    } else {
      b.write(' barrierType=$_barrierType');
      b.write(' barrier=$arg1');
    }
    b.write(' }');

    return 'Message$b';
  }
}
