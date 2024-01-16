class NullObjectError extends Error {
  final String message;

  NullObjectError(this.message);

  @override
  String toString() => 'NullObjectError: $message';
}
