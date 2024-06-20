import 'package:error_trace/error_trace.dart';
import 'package:stack_trace/stack_trace.dart';

extension StackTraceExtension on StackTrace {
  StackTrace withCauses(Object error) {
    if (error is Traceable) {
      final thisTrace = Trace.from(this);
      final causeTrace = Trace.from(
        error.causeStackTrace.withCauses(error.causeError),
      );
      return Trace(causeTrace.frames + thisTrace.frames).vmTrace;
    } else {
      return this;
    }
  }
}
