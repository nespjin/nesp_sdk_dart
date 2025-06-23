import 'package:meta/meta_meta.dart';

@Target({TargetKind.classType})
final class Compoment {
  const Compoment({
    this.modules = const {},
    this.dependencies = const {},
  });

  final Set<Type> modules;
  final Set<Type> dependencies;
}
