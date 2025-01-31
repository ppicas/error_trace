import 'dart:async';

import 'package:error_trace/error_trace.dart';

import 'fakes/firebase_fakes.dart';
import 'fakes/flutter_fakes.dart';
import 'fakes/network_fakes.dart';

// This example simulates a Flutter app integrated with Crashlytics.
//
// It uses fake versions of the Flutter and Crashlytics APIs for demonstration
// purposes.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(
      details.exception,
      // Use the `chainCauses` extension method from the `error_trace` package
      // to create a [Chain] that includes all the causes chained.
      //
      // [Chain] is a class provided by the `stack_trace` package that
      // implements [StackTrace] so it can be passed to Crashlytics.
      details.stack.chainCauses(details.exception),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(
      error,
      // Use the `chainCauses` extension method as before.
      stack.chainCauses(error),
      fatal: true,
    );
    return true;
  };

  // This will intentionally trigger `PlatformDispatcher.instance.onError`. The
  // uncaught error will be reported to Crashlytics by calling
  // `FirebaseCrashlytics.instance.recordError`.
  //
  // The `StackTrace` sent to Crashlytics will include the complete causal chain
  // of the error, thanks to the use of `chainCauses` and [Chain].
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  void init() {
    unawaited(_fetchData());
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
