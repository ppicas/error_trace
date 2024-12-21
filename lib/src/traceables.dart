import 'package:error_trace/src/traceable.dart';

/// [TraceableException] is an [Exception] that implements the
/// [Traceable] interface.
///
/// This allows it to be part of a chain of errors, where each error can
/// point to the error that caused it, along with the corresponding stack trace.
///
/// You can use this class directly to create exceptions that can be chained,
/// or you can extend it to create custom exception types that also support
/// chaining.
class TraceableException implements Exception, Traceable {
  /// Creates a [TraceableException].
  ///
  /// The [causeError] is the error that caused this error.
  ///
  /// The [causeStackTrace] is the stack trace of the error that caused this
  /// error.
  ///
  /// The [name] is an optional name for this error. It is used to format the
  /// string when [toString] is called. It represents the name of the error.
  ///
  /// The [message] is an optional message for this error. It is used to format
  /// the string when [toString] is called. It is a custom message explaining
  /// the reason for the error.
  TraceableException(
    this.causeError,
    this.causeStackTrace, {
    this.name,
    this.message,
  });

  /// An optional name for this error. It is used to format the string when
  /// [toString] is called. It represents the name of the error.
  final String? name;

  /// An optional message for this error. It is used to format the string when
  /// [toString] is called. It is a custom message explaining the reason for
  /// the error.
  final String? message;

  /// The error that caused this error.
  @override
  final Object causeError;

  /// The stack trace of the error that caused this error.
  @override
  final StackTrace causeStackTrace;

  @override
  String toString() {
    return _toString(this, name, 'Exception', message);
  }
}

/// [TraceableError] is an [Error] that implements the [Traceable] interface.
///
/// This allows it to be part of a chain of errors, where each error can
/// point to the error that caused it, along with the corresponding stack trace.
///
/// You can use this class directly to create errors that can be chained, or
/// you can extend it to create custom error types that also support chaining.
class TraceableError extends Error implements Traceable {
  /// Creates a [TraceableError].
  ///
  /// The [causeError] is the error that caused this error.
  ///
  /// The [causeStackTrace] is the stack trace of the error that caused this
  /// error.
  ///
  /// The [name] is an optional name for this error. It is used to format the
  /// string when [toString] is called. It represents the name of the error.
  ///
  /// The [message] is an optional message for this error. It is used to format
  /// the string when [toString] is called. It is a custom message explaining
  /// the reason for the error.
  TraceableError(
    this.causeError,
    this.causeStackTrace, {
    this.name,
    this.message,
  });

  /// An optional name for this error. It is used to format the string when
  /// [toString] is called. It represents the name of the error.
  final String? name;

  /// An optional message for this error. It is used to format the string when
  /// [toString] is called. It is a custom message explaining the reason for
  /// the error.
  final String? message;

  /// The error that caused this error.
  @override
  final Object causeError;

  /// The stack trace of the error that caused this error.
  @override
  final StackTrace causeStackTrace;

  @override
  String toString() {
    return _toString(this, name, 'Error', message);
  }
}

String _toString(
  Traceable traceable,
  String? typeName,
  String fallbackTypeName,
  String? errorMessage,
) {
  final message = errorMessage ?? '';
  final name = typeName ?? (message.isEmpty ? fallbackTypeName : '');
  final separator = name.isNotEmpty && message.isNotEmpty ? ': ' : '';
  return '$name$separator$message (Caused by: ${traceable.causeError})';
}
