/// An interface that represents a traceable error.
///
/// This interface can be implemented by errors and exceptions that need to
/// provide information about the causing error and its associated
/// stack traces.
///
/// The [causeError] property can be another [Traceable] object, allowing for
/// the creation of a chain of errors. This is useful for debugging and
/// understanding the sequence of events that led to an error.
abstract interface class Traceable {
  /// The error or exception that caused the current issue.
  ///
  /// This property provides a detailed explanation of what went wrong
  /// and is typically an exception or error object.
  ///
  /// It can also be another [Traceable] object, allowing for the creation of a
  /// chain of errors.
  Object get causeError;

  /// The stack trace associated with the cause of the error.
  ///
  /// This property provides a snapshot of the call stack at the point where
  /// the error or exception occurred, aiding in debugging and diagnostics.
  StackTrace get causeStackTrace;
}
