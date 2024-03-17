import 'dart:async';

abstract class Initializer<T> {
  Initializer({
    required this.id,
  });

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  final String id;

  FutureOr<T> initialize();

  FutureOr<void> performInitialize() async {
    if (_isInitialized) return;
    await initialize();
    _isInitialized = true;
  }

  List<String> dependencies() => List.empty();
}

class InitializerManager {
  static InitializerManager? _instance;

  static InitializerManager get shared => _instance ??= InitializerManager._();

  InitializerManager._();

  final _initializers = <String, Initializer>{};

  void initialize() {
    for (var entry in _initializers.entries) {
      final initializer = entry.value;
      final dependencies = entry.value.dependencies();
      for (var id in dependencies) {
        final dependency = _initializers[id];
        if (dependency?.isInitialized == false) {
          dependency?.performInitialize();
        }
      }
      initializer.performInitialize();
    }
    _dispose();
  }

  void addInitializer(Initializer initializer) {
    if (_initializers.containsKey(initializer.id)) return;
    _initializers[initializer.id] = initializer;
  }

  void _dispose() {
    _initializers.clear();
    _instance = null;
  }
}
