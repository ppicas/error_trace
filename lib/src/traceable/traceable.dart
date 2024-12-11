/// An interface that represents a traceable error.
///
/// This interface can be implemented by errors and exceptions that need to
/// provide information about the causing error and its associated
/// stack traces.
abstract interface class Traceable {
  /// The error or exception that caused the current issue.
  ///
  /// This property provides a detailed explanation of what went wrong
  /// and is typically an exception or error object.
  Object get causeError;

  /// The stack trace associated with the cause of the error.
  ///
  /// This property provides a snapshot of the call stack at the point where
  /// the error or exception occurred, aiding in debugging and diagnostics.
  StackTrace get causeStackTrace;
}
