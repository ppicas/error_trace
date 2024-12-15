import 'dart:convert';

import 'package:error_trace/src/traceable.dart';
import 'package:stack_trace/stack_trace.dart';

void printError(Object error, StackTrace st, {bool terse = true}) {
  print(formatError(error, st, terse: terse));
}

String formatError(Object error, StackTrace st, {bool terse = true}) {
  var text = '$error\n';

  text += st.toString().isNotEmpty
      ? Trace.format(st, terse: terse).trimRight()
      : 'Empty StackTrace';

  if (error is Traceable) {
    var causeText = '# Caused by:\n';
    causeText += formatError(error.causeError, error.causeStackTrace);
    text += '\n${causeText.indent()}';
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
    return lines.map((line) => _prefix + line).join('\n');
  }
}
