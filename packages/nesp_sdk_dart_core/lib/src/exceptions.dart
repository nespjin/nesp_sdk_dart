class NespException implements Exception {
  const NespException([this.message = '']) : parent = null;

  NespException.from([this.parent]) : message = '';

  final Exception? parent;
  final String message;

  @override
  String toString() {
    if (parent != null) {
      return 'NespException[parent=\'${parent.toString()}\']';
    }
    return 'NespException[message=\'$message\']';
  }
}
