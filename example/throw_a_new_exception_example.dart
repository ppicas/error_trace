import 'dart:async';

import 'package:error_trace/error_trace.dart';

void main() {
  runZonedGuarded(() {
    unawaited(doSomeNetworkWork().catchError((e, st) {
      throw CustomException('Some network work failed', e, st);
    }));
  }, (error, st) {
    printError(error, st);
  });
}

Future<void> doSomeNetworkWork() {
  return Future.delayed(Duration.zero).then((value) {
    return Future.error(Exception('Network error'), StackTrace.current);
  });
}

class CustomException extends TraceableException {
  CustomException(
    String message,
    super.causeError,
    super.causeStackTrace,
  ) : super(name: 'CustomException', message: message);
}
