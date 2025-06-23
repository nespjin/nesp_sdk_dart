import 'package:meta/meta_meta.dart';

@Target({TargetKind.classType})
final class Module {
  const Module({
    this.indcludes = const {},
    this.subcomponents = const {},
  });

  final Set<Type> indcludes;
  final Set<Type> subcomponents;
}
