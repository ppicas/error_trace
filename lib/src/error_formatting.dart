import 'dart:convert';

import 'package:error_trace/src/traceable.dart';
import 'package:stack_trace/stack_trace.dart';

/// Prints an error and its stack trace to the console.
///
/// If [error] implements [Traceable], this function will recursively format
/// the error's cause, creating a chain of errors in the output.
///
/// [error] and [stackTrace] are the error object and its associated
/// stack trace to format.
///
/// If [terse] is set to true (default), this folds together multiple stack
/// frames from the Dart core libraries, so that only the core library method
/// directly called from user code is visible.
void printError(Object error, StackTrace stackTrace, {bool terse = true}) {
  print(formatError(error, stackTrace, terse: terse));
}

/// Returns a formatted error and its stack trace into a readable string.
///
/// If [error] implements [Traceable], this function will recursively format
/// the error's cause, creating a chain of errors in the output.
///
/// [error] and [stackTrace] are the error object and its associated
/// stack trace to format.
///
/// If [terse] is set to true (default), this folds together multiple stack
/// frames from the Dart core libraries, so that only the core library method
/// directly called from user code is visible.
String formatError(Object error, StackTrace stackTrace, {bool terse = true}) {
  final buffer = StringBuffer();

  buffer.writeln(error);

  final st = switch (stackTrace) {
    StackTrace.empty when error is Error => error.stackTrace,
    StackTrace.empty => null,
    _ => stackTrace,
  };

  final formattedSt =
      st != null ? Trace.format(st, terse: terse) : 'unknown location';

  buffer.write(formattedSt.indent());

  if (error is Traceable) {
    buffer.writeln();
    buffer.write('Caused by: ');
    buffer.write(formatError(error.causeError, error.causeStackTrace));
  }

  return buffer.toString();
}

extension on String {
  static const _prefix = '  ';

  String indent() {
    final lines = LineSplitter.split(this);
    return lines.map((line) => _prefix + line).join('\n');
  }
}
