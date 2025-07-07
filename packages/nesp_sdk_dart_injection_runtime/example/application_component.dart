import 'package:nesp_sdk_dart_injection_runtime/src/annotation/compoment.dart';

import 'application.dart';
import 'http_module.dart';
import 'user_module.dart';

@Compoment(modules: {UserModule, HttpModule})
abstract interface class ApplicationComponent {
  void inject(Application application);
}

