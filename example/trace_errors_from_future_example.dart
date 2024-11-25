import 'dart:async';

import 'package:error_trace/error_trace.dart';

import 'fakes/network_fakes.dart';

void main() {
  runZonedGuarded(() {
    // Calls `doSomeNetworkWork()` without capturing the errors.
    unawaited(fakeNetworkOperation(fail: true));
  }, (error, stackTrace) {
    // In this case 'stackTrace' only contains the call to
    // `doSomeNetworkWork()` function and doesn't contain
    // any `main()` functions calls.
    // This makes hard to know when `doSomeNetworkWork()` was called.
    print('### Uncaught error (Without error capturing):');
    printError(error, stackTrace);
    print('');
  });

  runZonedGuarded(() {
    // Calls `doSomeNetworkWork()`, but this time capturing the errors.
    unawaited(fakeNetworkOperation(fail: true).traceErrors());
  }, (error, stackTrace) {
    // In this case `stackTrace` contains all the calls to
    // `doSomeNetworkWork`, and `main()` functions.
    // This makes easy to know when `doSomeNetworkWork()` was called.
    print('### Uncaught error (With error capturing):');
    printError(error, stackTrace);
    print('');
  });
}
