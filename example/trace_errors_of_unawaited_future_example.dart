// ignore_for_file: discarded_futures

import 'dart:async';

import 'package:error_trace/error_trace.dart';

import 'fakes/network_fakes.dart';

void main() {
  runZonedGuarded(() {
    // Calls `fakeNetworkOperation()` without chaining possible exceptions
    fakeNetworkOperation(fail: true);
  }, (error, stackTrace) {
    // In this case 'stackTrace' only contains the call to
    // `fakeNetworkOperation()` function and doesn't contain any `main()`
    // functions calls. This makes hard to know when `fakeNetworkOperation()`
    // was called.
    print('### Uncaught error (Without chaining exceptions):');
    printError(error, stackTrace);
    print('');
  });

  runZonedGuarded(() {
    // Calls `fakeNetworkOperation()` chaining possible exceptions by throwing a
    // `Traceable`.
    fakeNetworkOperation(fail: true)
        .catchError((e, st) => throw NetworkException(e, st));
  }, (error, stackTrace) {
    // In this case `stackTrace` contains all the calls to
    // `fakeNetworkOperation()`, and `main()` functions. This makes easy to know
    // when `fakeNetworkOperation()` was called.
    print('### Uncaught error (Chaining exceptions by throwing a Traceable):');
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
