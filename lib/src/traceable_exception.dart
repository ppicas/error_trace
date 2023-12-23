import 'package:error_trace/src/error_cause.dart';

class TraceableException implements Exception, ErrorCause {
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
