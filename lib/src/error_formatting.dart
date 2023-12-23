import 'dart:convert';

import 'package:error_trace/src/error_cause.dart';
import 'package:stack_trace/stack_trace.dart';

void printError(Object error, StackTrace st, {bool terse = true}) {
  print(formatError(error, st, terse: terse));
}

String formatError(Object error, StackTrace st, {bool terse = true}) {
  var text = '$error\n';

  text += st.toString().isNotEmpty
      ? Trace.format(st, terse: terse)
      : 'Empty StackTrace\n';

  if (error is ErrorCause) {
    var causeText = '# Caused by:\n';
    causeText += formatError(error.causeError, error.causeStackTrace);
    text += causeText.indent();
  }

  return text;
}

extension ExceptionFormatting on Exception {
  void print(StackTrace st, {bool terse = true}) {
    printError(this, st, terse: terse);
  }

  String format(StackTrace st, {bool terse = true}) {
    return formatError(this, st, terse: terse);
  }
}

extension ErrorFormatting on Error {
  void print(StackTrace st, {bool terse = true}) {
    printError(this, st, terse: terse);
  }

  String format(StackTrace st, {bool terse = true}) {
    return formatError(this, st, terse: terse);
  }
}

extension on String {
  static const _prefix = '  ';

  String indent() {
    final lines = LineSplitter.split(this);
    final indentedString = lines.map((line) => _prefix + line).join('\n');
    return endsWith('\n') ? '$indentedString\n' : indentedString;
  }
}
