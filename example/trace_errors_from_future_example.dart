import 'dart:async';

import 'package:error_trace/error_trace.dart';

void main() {
  runZonedGuarded(() {
    unawaited(doSomeNetworkWork().traceErrors());
  }, (error, st) {
    printError(error, st);
  });
}

Future<void> doSomeNetworkWork() {
  return Future.delayed(Duration.zero).then((value) {
    return Future.error(Exception('Network error'), StackTrace.current);
  });
}
