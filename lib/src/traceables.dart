import 'package:error_trace/src/traceable.dart';

class TraceableException implements Exception, Traceable {
  TraceableException(
    this.causeError,
    this.causeStackTrace, {
    this.name,
    this.message,
  });

  final String? name;

  final String? message;

  @override
  final Object causeError;

  @override
  final StackTrace causeStackTrace;

  @override
  String toString() {
    return _toString(this, name, 'Exception', message);
  }
}

class TraceableError extends Error implements Traceable {
  TraceableError(
    this.causeError,
    this.causeStackTrace, {
    this.name,
    this.message,
  });

  final String? name;

  final String? message;

  @override
  final Object causeError;

  @override
  final StackTrace causeStackTrace;

  @override
  String toString() {
    return _toString(this, name, 'Error', message);
  }
}

String _toString(
  Traceable traceable,
  String? typeName,
  String fallbackTypeName,
  String? errorMessage,
) {
  final message = errorMessage ?? '';
  final name = typeName ?? (message.isEmpty ? fallbackTypeName : '');
  final separator = name.isNotEmpty && message.isNotEmpty ? ': ' : '';
  return '$name$separator$message (Caused by: ${traceable.causeError})';
}
