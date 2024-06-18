import 'package:error_trace/src/traceable/traceable.dart';

class TraceableError extends Error implements Traceable {
  TraceableError(
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
