import 'dart:async';

import 'package:stack_trace/stack_trace.dart';

extension FutureErrorUtils<T> on Future<T> {
  Future<T> traceErrors() {
    final capturedST = StackTrace.current;
    return catchError((Object error, StackTrace errorST) {
      return Future<T>.error(error, _mixStackTraces(errorST, capturedST));
    });
  }
}

extension StreamErrorUtils<T> on Stream<T> {
  Stream<T> traceErrors() {
    final capturedST = StackTrace.current;
    return transform(
      StreamTransformer.fromHandlers(
        handleError: (error, errorST, sink) {
          sink.addError(error, _mixStackTraces(errorST, capturedST));
        },
      ),
    );
  }
}

final _inJS = Uri.base.scheme != 'file';

StackTrace _mixStackTraces(StackTrace st, StackTrace capturedST) {
  final trace = Trace.from(st);
  final capturedTrace = Trace.from(capturedST);
  final mixedTrace = Trace(
    // JS includes a frame for the call to StackTrace.current, but the VM
    // doesn't, so we skip an extra frame in a JS context.
    trace.frames + capturedTrace.frames.skip(_inJS ? 2 : 1).toList(),
  );
  return mixedTrace.vmTrace;
}
