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
      // Creates a [Chain] instance that includes all the causes chained.
      //
      // [Chain] is a class provided by `stack_trace` package that implements
      // [StackTrace] so it can be passed to Crashlytics.
      stack.chainCauses(error),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(
      error,
      // Creates a [Chain] instance that includes all the causes chained.
      //
      // [Chain] is a class provided by `stack_trace` package that implements
      // [StackTrace] so it can be passed to Crashlytics.
      stack.chainCauses(error),
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
      throw FetchException('Network operation failed', error, stack);
    }
  }

  @override
  Widget build() {
    return Text('Hello world!');
  }
}

class FetchException extends TraceableException {
  FetchException(
    String message,
    super.causeError,
    super.causeStackTrace,
  ) : super(name: 'FetchException', message: message);
}
