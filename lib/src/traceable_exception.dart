import 'package:error_trace/src/traceable.dart';

class TraceableException implements Exception, Traceable {
  TraceableException(
    this.causeError,
    this.causeStackTrace, {
    this.message,
  });

  final String? message;

  @override
  final Object causeError;

  @override
  final StackTrace causeStackTrace;

  @override
  String toString() {
    return message ?? super.toString();
  }
}
