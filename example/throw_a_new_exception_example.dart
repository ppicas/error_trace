import 'dart:async';

import 'package:error_trace/error_trace.dart';

import 'fakes/network_fakes.dart';

Future<void> main() async {
  try {
    // Calls a function that calls `fakeNetworkOperation()` without catching
    // possible exceptions.
    await callWithoutThrowingTraceable();
  } catch (error, stackTrace) {
    // In this case 'stackTrace' only contains the call to
    // `fakeNetworkOperation()` function and doesn't contain
    // `callWithoutThrowingTraceable()` or `main()` functions calls.
    // This makes hard to know when `fakeNetworkOperation()` was called.
    print('### Error without throwing a Traceable:');
    printError(error, stackTrace);
    print('');
  }

  try {
    // Calls a function that calls `fakeNetworkOperation()` catching possible
    // exceptions and throwing a `Traceable`.
    await callAndThrowTraceable();
  } catch (error, stackTrace) {
    // In this case `stackTrace` contains all the calls to
    // `fakeNetworkOperation()`, `callAndThrowTraceable()`, and `main()`
    // functions. This makes easy to know when `fakeNetworkOperation()` was
    // called.
    print('### Error throwing a Traceable:');
    printError(error, stackTrace);
    print('');
  }
}

Future<void> callWithoutThrowingTraceable() async {
  return fakeNetworkOperation(fail: true);
}

Future<void> callAndThrowTraceable() async {
  try {
    await fakeNetworkOperation(fail: true);
  } catch (e, st) {
    throw CustomTraceableException('Some network work failed', e, st);
  }
}

class CustomTraceableException extends TraceableException {
  CustomTraceableException(
    String message,
    super.causeError,
    super.causeStackTrace,
  ) : super(message: "CustomTraceableException: $message");
}
