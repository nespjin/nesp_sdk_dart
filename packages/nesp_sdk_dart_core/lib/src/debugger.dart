typedef DebugLogPrinter = void Function(String? message,
    {StackTrace? stackTrace});

DebugLogPrinter debugLogPrinter = _defaultDebugLogPrinter;

void _defaultDebugLogPrinter(String? message, {StackTrace? stackTrace}) {
  assert(() {
    print(message);
    if (stackTrace != null) print(stackTrace);
    return true;
  }());
}
