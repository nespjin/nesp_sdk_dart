import 'dart:io';

import 'package:nesp_sdk_dart_core/nesp_sdk_dart_core.dart';
import 'package:nesp_sdk_dart_dtx/nesp_sdk_dart_dtx.dart';
import 'package:nesp_sdk_dart_http/nesp_sdk_dart_http.dart';

class FileDownloader {
  FileDownloader({
    required this.downloadUrl,
    required this.destinationFile,
  });

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(minutes: 5),
      receiveTimeout: const Duration(hours: 2),
    ),
  );

  Dio dio = _dio;
  File destinationFile;
  String downloadUrl;
  OnFileDownloadListener? onFileDownloadListener;

  static const int _stateIdle = 0;
  static const int _stateDownloading = 1;
  static const int _stateCancelled = 2;
  static const int _stateSuccessful = 3;
  static const int _stateError = 4;

  int _state = _stateIdle;

  get state => _state;

  bool isDownloading() => state == _stateDownloading;

  bool isCancelled() => state == _stateCancelled;

  bool isFailed() => state == _stateError;

  bool isSuccessful() => state == _stateSuccessful;

  final CancelToken _cancelToken = CancelToken();

  Future<Result<int, Exception>> download() async {
    if (state == _stateDownloading) {
      const String errorMessage = 'Already downloading';
      return Result.error(const NespException(errorMessage));
    }

    final String downloadUrl = this.downloadUrl;
    if (downloadUrl.isBlank) {
      Exception exception = const NespException('The downloadUrl is empty');
      _notifyDownloadFailed(exception);
      return Result.error(exception);
    }

    if (!downloadUrl.startsWith('https://') &&
        !downloadUrl.startsWith('http://')) {
      Exception exception = const NespException(
          'The downloadUrl must start with https:// or http://');
      _notifyDownloadFailed(exception);
      return Result.error(exception);
    }

    final Dio dio = this.dio;
    try {
      _notifyDownloadProgressChanged(10000, 1);
      var response = await dio.download(downloadUrl, destinationFile.path,
          cancelToken: _cancelToken, onReceiveProgress: _onReceiveProgress);
      int statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode <= 299) {
        if (isCancelled()) {
          return Result.ok(0);
        }
        _notifyDownloadSuccess();
        return Result.ok(0);
      } else {
        Exception exception = NespException(response.statusMessage ?? '');
        _notifyDownloadFailed(exception);
        return Result.error(exception);
      }
    } on DioException catch (e) {
      if (isCancelled()) {
        return Result.ok(0);
      }
      Exception exception = NespException(e.message ?? '');
      _notifyDownloadFailed(exception);
      return Result.error(exception);
    } on Exception catch (e) {
      if (isCancelled()) {
        return Result.ok(0);
      }
      _notifyDownloadFailed(e);
      return Result.error(e);
    }
  }

  void cancel() {
    if (_state == _stateCancelled) {
      return;
    }
    _state = _stateCancelled;
    _notifyDownloadCancelled();
    _cancelToken.cancel();
  }

  void _onReceiveProgress(int count, int total) {
    _notifyDownloadProgressChanged(total, count);
  }

  void _notifyDownloadProgressChanged(int length, int downloadLength) {
    _state = _stateDownloading;
    var progress = 1.0;
    if (length > 0) {
      progress = downloadLength * 1.00 / length;
    }

    onFileDownloadListener?.onProgress(length, downloadLength, progress);
  }

  void _notifyDownloadSuccess() {
    _state = _stateSuccessful;
    onFileDownloadListener?.onSuccess();
  }

  void _notifyDownloadCancelled() {
    _state = _stateCancelled;
    onFileDownloadListener?.onCancelled();
  }

  void _notifyDownloadFailed(Exception exception) {
    _state = _stateError;
    onFileDownloadListener?.onFailed(exception);
  }
}

abstract class OnFileDownloadListener {
  void onProgress(int length, int downloadLength, double progress);

  void onSuccess();

  void onFailed(Exception? exception);

  void onCancelled();
}
