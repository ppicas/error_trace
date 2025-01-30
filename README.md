Dart tools that prevent stack trace loss across async operations, improving error diagnostics.

This package provides a set of lightweight tools to enhance error diagnostics in Dart and Flutter
applications by mitigating the loss of stack trace information for exceptions thrown during
asynchronous operations.

With `error_trace`, you can maintain complete stack traces, making debugging asynchronous code
significantly easier.

## Features

Use this package to:

- **Chain errors:** Throw exceptions that wrap the original error, preserving the context of the
  initial failure across asynchronous operations.
- **Preserve stack traces:** Maintain complete stack traces across `async`, `await`, and `Future`
  gaps, preventing loss of crucial call stack information.
- **Enhance crash reporting:** Report crashes with full, chained stack traces to services like
  Crashlytics or Sentry for better debugging.
- **Format error output:** Print chained errors in a clear, readable format, making it easier to
  understand the error sequence.
- **Improve debugging:** Quickly pinpoint the root cause of errors, even in complex asynchronous
  workflows.

## Getting started

First, add `error_trace` package to
your [pubspec dependencies](https://pub.dev/packages/error_trace/install).

After that, you can import the library and use it:

```dart
import 'package:error_trace/error_trace.dart';
```

## Usage

<details>
<summary>Background: Problems with exceptions in asynchronous operations</summary>

Debugging errors in asynchronous Dart code can be tricky. When an error occurs within an `async`
function, the resulting stack trace may be incomplete. This is because asynchronous operations
introduce "gaps" where the execution pauses and resumes. Across these gaps, the original call stack
can be lost, making it difficult to trace the error back to its source.
</details>

Consider the following Dart code:

```dart
Future<void> fetchData() async {
  await Future.delayed(Duration(milliseconds: 100));
  throw Exception('Failed to fetch data');
}

Future<void> processData() async {
  await fetchData();
}

void main() {
  processData().catchError((error, stackTrace) {
    print('Caught an error:\n$error\n');
    print('Stack trace:\n$stackTrace');
  });
}
```

When you run this code, you might expect the stack trace to show that the error originated in
`fetchData` and was called by `processData`. However, the output might look something like this:

```
Caught an error:
Exception: Failed to fetch data

Stack trace:
#0 fetchData.<anonymous closure> (file:///path/to/your/file.dart:2:9) <asynchronous suspension>
#1 Future.Future.microtask.<anonymous closure> (dart:async/future_patch.dart:187:31) <asynchronous suspension>
```

Notice that the stack trace doesn't show that `processData` called `fetchData`. The asynchronous gap
introduced by `await Future.delayed` has caused the loss of that part of the call stack. This makes
it harder to understand the sequence of events that led to the error.

To preserve the complete stack trace across asynchronous operations we transform the above code by
using `error_trace` in the following way:

```dart
Future<void> fetchData() async {
  await Future.delayed(Duration(milliseconds: 100));
  throw Exception('Failed to fetch data');
}

Future<void> processData() async {
  try {
    await fetchData();
  } catch (e, st) {
    // Throw a TraceableException that includes the cause exception details
    throw TraceableException(e, st, message: 'Process data exception');
  }
}

void main() {
  processData().catchError((error, stackTrace) {
    print('Caught an error:');
    // Use printError to print the chain of errors with the complete stack trace
    printError(error, stackTrace);
  });
}
```

Now, the output might look something like this:

```
Caught an error:
Process data exception (Caused by: Exception: Failed to fetch data)
  at path/to/your/file.dart 6:13  processData
  at path/to/your/file.dart 14:5  main
Caused by: Exception: Failed to fetch data
  at path/to/your/file.dart 1:9  fetchData
```

Notice that the stack trace now shows that `processData` called `fetchData`.

You can
check [trace_errors_from_async_function_example.dart](example/trace_errors_from_async_function_example.dart)
for a more detailed example.

### Chaining exceptions

To prevent the loss of the stack trace you have to catch the exceptions that are thrown by other
parts of the code and throw a `Traceable` that wraps the cause exceptions.

`Traceable` is an interface that you can implement to create your own traceable exceptions or
errors. It has two properties:

- `causeError`: The original error that caused this exception or error.
- `causeStackTrace`: The stack trace of the original error.

`TraceableException` and `TraceableError` are ready-to-use classes that implement the `Traceable`
interface. These classes extend `Exception` and `Error`, respectively:

```dart
Future<void> main() async {
  try {
    await operationThatMayThrow();
  } on Exception catch (e, st) {
    throw TraceableException(e, st);
  } on Error catch (e, st) {
    throw TraceableError(e, st);
  }
}
```

Also, you can extend these classes if you want to implement your own `Traceable` exceptions or
errors:

```dart
class MyException extends TraceableException {
  MyException(
    super.causeError, // The original error that caused this exception.
    super.causeStackTrace, // The stack trace of the original error.
  ) : super(name: 'MyException');
}

// Or

class MyError extends TraceableError {
  MyError(
    String message, // A message describing the error.
    super.causeError, // The original error that caused this error.
    super.causeStackTrace, // The stack trace of the original error.
  ) : super(name: 'MyError', message: message);
}
```

There is more info about theses classes in
the [API reference](https://pub.dev/documentation/error_trace/latest/error_trace/).

#### Chaining using `Future` callbacks

Use `Future.catchError` to chain exceptions in a code that doesn't use `async` and `await`:

```dart
Future<void> processData() {
  return fetchData().catchError((e, st) {
    throw TraceableException(e, st, message: 'Process data exception');
  });
}
```

You can
check [trace_errors_of_unawaited_future_example.dart](example/trace_errors_of_unawaited_future_example.dart)
for a more detailed example.

### Printing errors

The `error_trace` package provides a convenient way to print chained errors with their complete
stack traces using the `printError` function. This function recursively traverses the chain of
`Traceable` exceptions or errors, printing each one along with its stack trace in a clear, readable
format.

Here's how you can use it:

```dart
void main() {
  runZonedGuarded(() {
    // Some operations that throw exceptions...
  }, (error, stackTrace) {
    print('Uncaught error:');
    printError(error, stackTrace);
  });
}
```

It prints the error details formated like this:

```
FooException: Foo failed (Caused by: BarException: Bar failed (Caused by: Exception))
  at path/to/your/foo.dart 6:13   fooFunction
  at path/to/your/file.dart 14:5  main
Caused by: BarException: Bar failed (Caused by: Exception)
  at path/to/your/bar.dart 3:3   someFunction
  at path/to/your/bar.dart 10:6  barFunction
Caused by: Exception
  at path/to/your/another.dart 3:15  anotherFunction
```

You can check the [API reference](https://pub.dev/documentation/error_trace/latest/error_trace/) for
additional formating tools.

### Reporting errors

The `error_trace` package makes it easy to report chained errors to services like Firebase
Crashlytics or Sentry.

#### Reporting errors to Crashlytics

You can use `chainCauses` with Crashlytics in the following way:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(
      errorDetails.exception,
      // Creates a [Chain] instance that includes all the causes chained
      errorDetails.stack.chainCauses(error),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(
      error,
      // Creates a [Chain] instance that includes all the causes chained
      stack.chainCauses(error),
      fatal: true,
    );
    return true;
  };

  // ...
}
```

The `chainCauses` extension method on `StackTrace` combines multiple stack traces from a chain of
errors into a single `Chain` object. This object is provided by the `stack_trace` package and can be
passed to Crashlytics because it implements `StackTrace`.

More info on how to setup Crashlytics can be
found [here](https://firebase.flutter.dev/docs/crashlytics/usage).

#### Reporting errors to Sentry

You can provide an `ExceptionCauseExtractor` that extracts causes from `Traceable` errors in the
following way:

```dart
class _TraceableExtractor extends ExceptionCauseExtractor<Traceable>  {
  @override
  ExceptionCause? cause(Traceable error) {
    return ExceptionCause(error.causeError, error.causeStackTrace);
  }
}

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.addExceptionCauseExtractor(_TraceableExtractor());
    },
    // Init your App
    appRunner: () => runApp(MyApp()),
  );
}
```

More info on how to setup Sentry can be found [here](https://pub.dev/packages/sentry_flutter).

## Additional information

Under the hood, this package uses the [stack_trace](https://pub.dev/packages/stack_trace) package to
manipulate and format stack trace. Take a look on it if you want to make more advanced features.

You will notice that `stack_trace` provides `Chain.capture` that also solves the problem of losing
stack trace information in asynchronous operations. It's a good solution, however, it's not
recommended for production code because the performance overhead of creating new zones to capture
the stack trace.