import 'package:nesp_sdk_dart_injection_runtime/src/annotation/binds.dart';
import 'package:nesp_sdk_dart_injection_runtime/src/annotation/module.dart';

import 'http_client.dart';

@Module()
abstract class HttpModule {
  @Binds()
  HttpClient2 bindsHttpClient(HttpClientImpl httpClient);
}