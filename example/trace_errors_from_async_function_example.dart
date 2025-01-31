import 'dart:async';

import 'package:error_trace/error_trace.dart';

import 'fakes/network_fakes.dart';

Future<void> main() async {
  try {
    // Calls a function that calls `fakeNetworkOperation()` without chaining
    // possible exceptions.
    await fetchData(chainExceptions: false);
  } catch (error, stackTrace) {
    // In this case the printed stack trace only contains the call to
    // `fakeNetworkOperation()` function and doesn't contain `fetchData()` or
    // `main()` functions calls. This makes hard to know when
    // `fakeNetworkOperation()` was called.
    print('### Error without chaining exceptions:');
    printError(error, stackTrace);
    print('');
  }

  try {
    // Calls a function that calls `fakeNetworkOperation()` chaining possible
    // exceptions by throwing a `Traceable`.
    await fetchData(chainExceptions: true);
  } catch (error, stackTrace) {
    // In this case the printed stack trace contains all the calls to
    // `fakeNetworkOperation()`, `fetchData()`, and `main()` functions. This
    // makes easy to know when `fakeNetworkOperation()` was called.
    print('### Error chaining exceptions by throwing a Traceable:');
    printError(error, stackTrace);
    print('');
  }
}

Future<void> fetchData({required bool chainExceptions}) async {
  if (chainExceptions) {
    try {
      await fakeNetworkOperation(fail: true);
    } catch (e, st) {
      throw NetworkException(e, st);
    }
  } else {
    return fakeNetworkOperation(fail: true);
  }
}

class NetworkException extends TraceableException {
  NetworkException(
    super.causeError,
    super.causeStackTrace,
  ) : super(name: 'NetworkException');
}
