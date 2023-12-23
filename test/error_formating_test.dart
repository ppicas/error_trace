import 'package:error_trace/error_trace.dart';
import 'package:test/test.dart';

void main() {
  final fakeST = StackTrace.fromString(
    '#0      main (file:///test.dart:1:1)\n'
    '#1      _rootRun (dart:async/zone.dart:1399:13)\n',
  );

  test(
    'Should not add the cause '
    'when the exception doesn\'t implement ErrorCause',
    () {
      final error = _MockException();

      final text = error.format(fakeST);

      expect(
        text,
        'MockException\n'
        '/test.dart 1:1  main\n',
      );
    },
  );

  test(
    'Should add the cause '
    'when the exception implements ErrorCause',
    () {
      final error1 = _MockException();

      final error2 = _MockTraceableException(
        error1,
        fakeST,
        message: 'Error 2',
      );

      final error3 = _MockTraceableException(
        error2,
        fakeST,
        message: 'Error 3',
      );

      final text = error3.format(fakeST);

      expect(
          text,
          'MockTraceableException: Error 3\n'
          '/test.dart 1:1  main\n'
          '  # Caused by:\n'
          '  MockTraceableException: Error 2\n'
          '  /test.dart 1:1  main\n'
          '    # Caused by:\n'
          '    MockException\n'
          '    /test.dart 1:1  main\n');
    },
  );

  test(
    'Should add "Empty StackTrace" '
    'when the StackTrace is empty',
    () {
      final error = _MockException();

      final text = error.format(StackTrace.empty);

      expect(
        text,
        'MockException\n'
        'Empty StackTrace\n',
      );
    },
  );

  test(
    'Should not filter Dart code lines from the StackTrace '
    'when terse parameter is false',
    () {
      final error = _MockException();

      final text = error.format(fakeST, terse: false);

      expect(
        text,
        'MockException\n'
        '/test.dart 1:1                main\n'
        'dart:async/zone.dart 1399:13  _rootRun\n',
      );
    },
  );
}

class _MockException implements Exception {
  @override
  String toString() {
    return 'MockException';
  }
}

class _MockTraceableException extends TraceableException {
  _MockTraceableException(
    super.causeError,
    super.causeStackTrace, {
    super.message,
  }) : super(name: 'MockTraceableException');
}
