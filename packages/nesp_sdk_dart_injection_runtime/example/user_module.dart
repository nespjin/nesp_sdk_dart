import 'package:nesp_sdk_dart_injection_runtime/src/annotation/binds.dart';
import 'package:nesp_sdk_dart_injection_runtime/src/annotation/module.dart';
import 'package:nesp_sdk_dart_injection_runtime/src/annotation/provides.dart';

import 'animal.dart';
import 'dog.dart';
import 'user.dart';

@Module()
abstract class UserModule {
  @Provides()
  User providerUser() {
    return const User('张三', 18);
  }

  @Binds()
  Animal bindsAnimal(Dog dog);
}
