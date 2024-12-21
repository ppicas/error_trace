import 'package:error_trace/error_trace.dart';
import 'package:stack_trace/stack_trace.dart';

/// Extension on the [StackTrace] class to provide functionality for chaining
/// together multiple stack traces from a chain of errors.
extension StackTraceExtension on StackTrace {
  /// Chains together the stack traces of multiple errors.
  ///
  /// This method takes an [error] object and recursively traverses the chain
  /// of errors, collecting the stack trace at each step. It expects errors
  /// to implement the [Traceable] interface to provide access to the cause
  /// error and its stack trace.
  ///
  /// If the passed [error] does not implement [Traceable], it will be
  /// considered as the last error in the chain, and only the current
  /// stack trace will be included in the result.
  ///
  /// The method returns a [Chain] object that contains the ordered list of
  /// [Trace] objects, each representing a single stack trace in the chain.
  ///
  /// Example:
  /// ```dart
  /// FlutterError.onError = (error, stack) {
  ///   // Records the unhandled error using Firebase Crashlytics
  ///   FirebaseCrashlytics.instance.recordFlutterFatalError(
  ///     error,
  ///     // Creates a [Chain] instance that includes all the causes chained.
  ///     //
  ///     // [Chain] is a class provided by `stack_trace` package that
  ///     // implements [StackTrace] so it can be passed to Crashlytics.
  ///     stack.chainCauses(error),
  ///   );
  /// };
  /// ```
  Chain chainCauses(Object error) {
    final traces = [Trace.from(this)];

    var current = error;
    while (true) {
      if (current is Traceable) {
        traces.insert(0, Trace.from(current.causeStackTrace));
        current = current.causeError;
      } else {
        break;
      }
    }

    return Chain(traces);
  }
}
