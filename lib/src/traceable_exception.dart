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
    final type = name ?? runtimeType.toString();
    return message != null ? '$type: $message' : type;
  }
}
