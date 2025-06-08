// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:isolate';

typedef WorkerHandler = WorkResponse Function(WorkRequest request);

class Worker {
  late SendPort _sendPort;
  late Isolate _isolate;
  final _isolateReady = Completer<void>();
  final Map<Capability, Completer> _cps = {};
  final WorkerHandler handler;

  Worker(this.handler) {
    _init();
  }

  void dispose() {
    _isolate.kill();
  }

  Future<void> _init() async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();
    errorPort.listen(print);
    receivePort.listen(_handleMessage);
    _isolate = await Isolate.spawn(
      _isolateEntry,
      receivePort.sendPort,
      onError: errorPort.sendPort,
    );
  }

  Future<dynamic> request(dynamic message) async {
    await _isolateReady.future;
    final completer = Completer();
    final requestId = Capability();
    _cps[requestId] = completer;
    _sendPort.send(WorkRequest(requestId, message));
    return completer.future;
  }

  void _handleMessage(message) {
    if (message is SendPort) {
      _sendPort = message;
      _sendPort.send(handler);
      _isolateReady.complete();
      return;
    }
    if (message is WorkResponse) {
      final completer = _cps[message.requestId];
      if (completer == null) {
        print("Invalid request ID received.");
      } else if (message.success) {
        completer.complete(message.message);
      } else {
        completer.completeError(message.message);
      }
      _cps.remove(message.requestId);
      return;
    }
    throw UnimplementedError("Undefined behavior for message: $message");
  }

  static void _isolateEntry(dynamic message) {
    late SendPort sendPort;
    late WorkerHandler handler;
    final receivePort = ReceivePort();

    receivePort.listen((dynamic message) async {
      if (message is WorkerHandler) {
        handler = message;
        return;
      }

      if (message is WorkRequest) {
        sendPort.send(handler(message));
        return;
      }
    });

    if (message is SendPort) {
      sendPort = message;
      sendPort.send(receivePort.sendPort);
      return;
    }
  }
}

class WorkRequest {
  /// The ID of the request so the response may be associated to
  /// the request's future completer.
  final Capability id;

  /// The actual message of the request.
  final dynamic message;

  const WorkRequest(this.id, this.message);
}

class WorkResponse {
  /// The ID of the request this response is meant to.
  final Capability requestId;

  /// Indicates if the request succeeded.
  final bool success;

  /// If [success] is true, holds the response message.
  /// Otherwise, holds the error that occured.
  final dynamic message;

  const WorkResponse.ok(this.requestId, this.message) : success = true;

  const WorkResponse.error(this.requestId, this.message) : success = false;
}
