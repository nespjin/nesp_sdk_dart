// Copyright 2025, the nesp_sdk_dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'package:dio/dio.dart';

class RequestInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);
    options.headers['Date'] = '${DateTime.now()}';

    _printRequestLog(options);
  }

  void _printRequestLog(RequestOptions options) {
    var message = '--> ${options.method} ${options.uri}\n';

    final headers = options.headers;
    if (headers.isNotEmpty) {
      for (var header in headers.entries) {
        final value = header.value;
        if (value is List<dynamic> && value.isNotEmpty) {
          for (var element in value) {
            message += '${header.key}: $element\n';
          }
        } else {
          message += '${header.key}: $value\n';
        }
      }
    }

    if (options.data != null) {
      message += options.data is Map<dynamic, dynamic>
          ? jsonEncode(options.data)
          : options.data;
      message += '\n';
    }

    message += '--> End ${options.method}';
    print('${_nowTime()} $message');
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
    _printResponseLog(response);
  }

  void _printResponseLog(Response<dynamic> response) {
    var message = '<-- ${response.statusCode} ${response.realUri}';

    final requestDate = response.requestOptions.headers['Date'] as String?;
    if (requestDate != null) {
      var responseDate = DateTime.now();
      final duration = responseDate.difference(DateTime.parse(requestDate));
      message += '(${duration.inMilliseconds}ms)';
    }

    message += '\n';

    final headers = response.headers;
    if (!headers.isEmpty) {
      for (var header in headers.map.entries) {
        final value = header.value;
        if (header.value.isNotEmpty) {
          for (var element in header.value) {
            message += '${header.key}: $element\n';
          }
        } else {
          message += '${header.key}: $value\n';
        }
      }
    }

    message += '$response\n';
    message += '<-- End Http';
    print('${_nowTime()} $message');
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);

    _printError(err);
  }

  void _printError(DioException exception) {
    if (exception.type == DioExceptionType.cancel) {
      return;
    }

    var message = '<-- Error ${exception.requestOptions.uri}\n';
    message += '${exception.message}\n';
    message += '<-- End Http';
    print('${_nowTime()} $message');
  }

  String _nowTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute}:${now.second}.${now.millisecond}';
  }
}
