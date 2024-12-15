// ignore_for_file: discarded_futures

import 'dart:async';

import 'package:error_trace/error_trace.dart';

import 'fakes/network_fakes.dart';

void main() {
  runZonedGuarded(() {
    // Calls `fakeNetworkOperation()` without capturing the errors.
    fakeNetworkOperation(fail: true);
  }, (error, stackTrace) {
    // In this case 'stackTrace' only contains the call to
    // `fakeNetworkOperation()` function and doesn't contain
    // any `main()` functions calls.
    // This makes hard to know when `fakeNetworkOperation()` was called.
    print('### Uncaught error (Without error capturing):');
    printError(error, stackTrace);
    print('');
  });

  runZonedGuarded(() {
    // Calls `fakeNetworkOperation()`, but this time capturing the errors.
    fakeNetworkOperation(fail: true)
        .catchError((e, st) => throw NetworkException(e, st));
  }, (error, stackTrace) {
    // In this case `stackTrace` contains all the calls to
    // `fakeNetworkOperation()`, and `main()` functions.
    // This makes easy to know when `fakeNetworkOperation()` was called.
    print('### Uncaught error (With error capturing):');
    printError(error, stackTrace);
    print('');
  });
}

class NetworkException extends TraceableException {
  NetworkException(
    super.causeError,
    super.causeStackTrace,
  ) : super(name: 'NetworkException');
}
