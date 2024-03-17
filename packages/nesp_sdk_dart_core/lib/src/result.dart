import 'package:nesp_sdk_dart_core/nesp_sdk_dart_core.dart';

sealed class Result {
  const Result();

  static SuccessResult<T> success<T>(T value) => SuccessResult(value);

  static ErrorResult failure({
    int? code,
    String message = '',
    Exception? exception,
  }) {
    return ErrorResult(code: code, message: message, exception: exception);
  }
}

final class SuccessResult<T> extends Result {
  const SuccessResult(this.value);

  final T value;

  @override
  String toString() {
    return 'SuccessResult(value=$value)';
  }
}

final class ErrorResult extends Result {
  const ErrorResult({
    this.code,
    this.message = '',
    this.exception,
  });

  factory ErrorResult.code(int code) {
    return ErrorResult(code: code);
  }

  factory ErrorResult.message(String message) {
    return ErrorResult(message: message);
  }

  factory ErrorResult.exception(Exception exception) {
    return ErrorResult(exception: exception);
  }

  final int? code;
  final String message;
  final Exception? exception;

  @override
  String toString() {
    return 'ErrorResult(code=$code,message=$message, exception=$exception)';
  }
}
