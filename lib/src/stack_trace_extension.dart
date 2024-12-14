import 'package:error_trace/error_trace.dart';
import 'package:stack_trace/stack_trace.dart';

extension StackTraceExtension on StackTrace {
  Chain chainCauses(Object error) {
    final traces = [Trace.from(this)];

    var current = error;
    while (true) {
      if (current is Traceable) {
        traces.insert(0, Trace.from(current.causeStackTrace));
        current = current.causeError;
      } else {
        break;
      }
    }

    return Chain(traces);
  }
}
