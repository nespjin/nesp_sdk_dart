import 'package:nesp_sdk_dart_injection_runtime/src/annotation/inject.dart';

import 'animal.dart';
import 'user.dart';

class Application {
  @Inject()
  late User user;

  @Inject()
  late Animal animal;

  void init() {
  }
}
