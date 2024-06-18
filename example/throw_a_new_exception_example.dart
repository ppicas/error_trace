import 'dart:async';

import 'package:error_trace/error_trace.dart';

Future<void> main() async {
  try {
    // Calls a function that calls `doSomeNetworkWork()` without catching
    // possible exceptions.
    await callWithoutThrowingTraceable();
  } catch (error, stackTrace) {
    // In this case 'stackTrace' only contains the call to
    // `doSomeNetworkWork()` function and doesn't contain
    // `callWithoutThrowingTraceable()` or `main()` functions calls.
    // This makes hard to know when `doSomeNetworkWork()` was called.
    print('### Error without throwing a Traceable:');
    printError(error, stackTrace);
    print('');
  }

  try {
    // Calls a function that calls `doSomeNetworkWork()` catching possible
    // exceptions and throwing a `Traceable`.
    await callAndThrowTraceable();
  } catch (error, stackTrace) {
    // In this case `stackTrace` contains all the calls to
    // `doSomeNetworkWork`, `callAndThrowTraceable()`, and `main()` functions.
    // This makes easy to know when `doSomeNetworkWork()` was called.
    print('### Error throwing a Traceable:');
    printError(error, stackTrace);
    print('');
  }
}

Future<void> callWithoutThrowingTraceable() async {
  return doSomeNetworkWork();
}

Future<void> callAndThrowTraceable() async {
  try {
    await doSomeNetworkWork();
  } catch (e, st) {
    throw CustomTraceableException('Some network work failed', e, st);
  }
}

Future<void> doSomeNetworkWork() {
  return Future.delayed(Duration.zero, () {
    throw Exception('Network error');
  });
}

class CustomTraceableException extends TraceableException {
  CustomTraceableException(
    String message,
    super.causeError,
    super.causeStackTrace,
  ) : super(message: "CustomTraceableException: $message");
}
