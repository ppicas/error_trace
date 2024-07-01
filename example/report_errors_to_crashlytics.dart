import 'dart:async';

import 'package:error_trace/error_trace.dart';

import 'fakes/firebase_fakes.dart';
import 'fakes/flutter_fakes.dart';
import 'fakes/network_fakes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FlutterError.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(
      error,
      // Pass a [StackTrace] including all the causes
      stack.withCauses(error),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(
      error,
      // Pass a [StackTrace] including all the causes
      stack.withCauses(error),
      fatal: true,
    );
    return true;
  };

  // This will trigger `PlatformDispatcher.instance.onError`. The uncaught
  // error will be reported to Crashlytics by calling
  // `FirebaseCrashlytics.instance.recordError`.
  //
  // The `StackTrace` sent to Crashlytics will include all the causes that
  // generated the error.
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  void init() {
    unawaited(_fetchData().traceErrors());
  }

  Future<void> _fetchData() async {
    try {
      await fakeNetworkOperation(fail: true);
    } catch (error, stack) {
      throw CustomTraceableException('Network operation failed', error, stack);
    }
  }

  @override
  Widget build() {
    return Text('Hello world!');
  }
}

class CustomTraceableException extends TraceableException {
  CustomTraceableException(
    String message,
    super.causeError,
    super.causeStackTrace,
  ) : super(message: 'CustomTraceableException: $message');
}
