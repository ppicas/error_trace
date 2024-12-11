import 'package:error_trace/error_trace.dart';
import 'package:test/test.dart';

void main() {
  final fakeST = StackTrace.fromString(
    '#0      main (file:///test.dart:1:1)\n'
    '#1      _rootRun (dart:async/zone.dart:1399:13)\n',
  );

  group('ErrorFormatting', () {
    test(
      'Should not add the cause '
      'when the exception doesn\'t implement `Traceable`',
      () {
        final error = _Error('Error');

        final text = error.format(fakeST);

        expect(
          text,
          'Error\n'
          '/test.dart 1:1  main',
        );
      },
    );

    test(
      'Should add the cause '
      'when the exception implements `Traceable`',
      () {
        final error1 = _Error('Error 1');

        final error2 = _TraceableError(
          'Error 2',
          error1,
          fakeST,
        );

        final error3 = _TraceableError(
          'Error 3',
          error2,
          fakeST,
        );

        final text = error3.format(fakeST);

        expect(
          text,
          'Error 3 (Caused by: Error 2 (Caused by: Error 1))\n'
          '/test.dart 1:1  main\n'
          '  # Caused by:\n'
          '  Error 2 (Caused by: Error 1)\n'
          '  /test.dart 1:1  main\n'
          '    # Caused by:\n'
          '    Error 1\n'
          '    /test.dart 1:1  main',
        );
      },
    );

    test(
      'Should add "Empty StackTrace" '
      'when the StackTrace is empty',
      () {
        final error = _Error('Error');

        final text = error.format(StackTrace.empty);

        expect(
          text,
          'Error\n'
          'Empty StackTrace',
        );
      },
    );

    test(
      'Should not filter Dart code lines from the StackTrace '
      'when terse parameter is false',
      () {
        final error = _Error('Error');

        final text = error.format(fakeST, terse: false);

        expect(
          text,
          'Error\n'
          '/test.dart 1:1                main\n'
          'dart:async/zone.dart 1399:13  _rootRun',
        );
      },
    );
  });

  group('ExceptionFormatting', () {
    test(
      'Should not add the cause '
      'when the exception doesn\'t implement `Traceable`',
      () {
        final error = _Exception('Exception');

        final text = error.format(fakeST);

        expect(
          text,
          'Exception\n'
          '/test.dart 1:1  main',
        );
      },
    );

    test(
      'Should add the cause '
      'when the exception implements `Traceable`',
      () {
        final error1 = _Exception('Exception 1');

        final error2 = _TraceableException(
          'Exception 2',
          error1,
          fakeST,
        );

        final error3 = _TraceableException(
          'Exception 3',
          error2,
          fakeST,
        );

        final text = error3.format(fakeST);

        expect(
          text,
          'Exception 3 (Caused by: Exception 2 (Caused by: Exception 1))\n'
          '/test.dart 1:1  main\n'
          '  # Caused by:\n'
          '  Exception 2 (Caused by: Exception 1)\n'
          '  /test.dart 1:1  main\n'
          '    # Caused by:\n'
          '    Exception 1\n'
          '    /test.dart 1:1  main',
        );
      },
    );

    test(
      'Should add "Empty StackTrace" '
      'when the StackTrace is empty',
      () {
        final error = _Exception('Exception');

        final text = error.format(StackTrace.empty);

        expect(
          text,
          'Exception\n'
          'Empty StackTrace',
        );
      },
    );

    test(
      'Should not filter Dart code lines from the StackTrace '
      'when terse parameter is false',
      () {
        final error = _Exception('Exception');

        final text = error.format(fakeST, terse: false);

        expect(
          text,
          'Exception\n'
          '/test.dart 1:1                main\n'
          'dart:async/zone.dart 1399:13  _rootRun',
        );
      },
    );
  });
}

class _Error extends Error {
  _Error(this.message);

  final String message;

  @override
  String toString() => message;
}

class _TraceableError extends TraceableError {
  _TraceableError(
    String message,
    super.causeError,
    super.causeStackTrace,
  ) : super(message: message);
}

class _Exception implements Exception {
  _Exception(this.message);

  final String message;

  @override
  String toString() => message;
}

class _TraceableException extends TraceableException {
  _TraceableException(
    String message,
    super.causeError,
    super.causeStackTrace,
  ) : super(message: message);
}
