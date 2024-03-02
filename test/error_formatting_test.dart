import 'package:error_trace/error_trace.dart';
import 'package:test/test.dart';

void main() {
  final fakeST = StackTrace.fromString(
    '#0      main (file:///test.dart:1:1)\n'
    '#1      _rootRun (dart:async/zone.dart:1399:13)\n',
  );

  group('With TraceableError', () {
    test(
      'Should not add the cause '
      'when the exception doesn\'t implement ErrorCause',
      () {
        final error = _Error();

        final text = error.format(fakeST);

        expect(
          text,
          'Error [_Error]\n'
          '/test.dart 1:1  main',
        );
      },
    );

    test(
      'Should add the cause '
      'when the exception implements ErrorCause',
      () {
        final error1 = _Error();

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
            'TraceableError: Error 3 [_TraceableError]\n'
            '/test.dart 1:1  main\n'
            '  # Caused by:\n'
            '  TraceableError: Error 2 [_TraceableError]\n'
            '  /test.dart 1:1  main\n'
            '    # Caused by:\n'
            '    Error [_Error]\n'
            '    /test.dart 1:1  main');
      },
    );

    test(
      'Should add "Empty StackTrace" '
      'when the StackTrace is empty',
      () {
        final error = _Error();

        final text = error.format(StackTrace.empty);

        expect(
          text,
          'Error [_Error]\n'
          'Empty StackTrace',
        );
      },
    );

    test(
      'Should not filter Dart code lines from the StackTrace '
      'when terse parameter is false',
      () {
        final error = _Error();

        final text = error.format(fakeST, terse: false);

        expect(
          text,
          'Error [_Error]\n'
          '/test.dart 1:1                main\n'
          'dart:async/zone.dart 1399:13  _rootRun',
        );
      },
    );
  });

  group('With TraceableException', () {
    test(
      'Should not add the cause '
      'when the exception doesn\'t implement ErrorCause',
      () {
        final error = _Exception();

        final text = error.format(fakeST);

        expect(
          text,
          'Exception [_Exception]\n'
          '/test.dart 1:1  main',
        );
      },
    );

    test(
      'Should add the cause '
      'when the exception implements ErrorCause',
      () {
        final error1 = _Exception();

        final error2 = _TraceableException(
          'Error 2',
          error1,
          fakeST,
        );

        final error3 = _TraceableException(
          'Error 3',
          error2,
          fakeST,
        );

        final text = error3.format(fakeST);

        expect(
            text,
            'TraceableException: Error 3 [_TraceableException]\n'
            '/test.dart 1:1  main\n'
            '  # Caused by:\n'
            '  TraceableException: Error 2 [_TraceableException]\n'
            '  /test.dart 1:1  main\n'
            '    # Caused by:\n'
            '    Exception [_Exception]\n'
            '    /test.dart 1:1  main');
      },
    );

    test(
      'Should add "Empty StackTrace" '
      'when the StackTrace is empty',
      () {
        final error = _Exception();

        final text = error.format(StackTrace.empty);

        expect(
          text,
          'Exception [_Exception]\n'
          'Empty StackTrace',
        );
      },
    );

    test(
      'Should not filter Dart code lines from the StackTrace '
      'when terse parameter is false',
      () {
        final error = _Exception();

        final text = error.format(fakeST, terse: false);

        expect(
          text,
          'Exception [_Exception]\n'
          '/test.dart 1:1                main\n'
          'dart:async/zone.dart 1399:13  _rootRun',
        );
      },
    );
  });
}

class _Error extends Error {
  @override
  String toString() {
    return 'Error';
  }
}

class _TraceableError extends TraceableError {
  _TraceableError(
    String message,
    super.causeError,
    super.causeStackTrace,
  ) : super(
          name: 'TraceableError',
          message: message,
        );
}

class _Exception implements Exception {
  @override
  String toString() {
    return 'Exception';
  }
}

class _TraceableException extends TraceableException {
  _TraceableException(
    String message,
    super.causeError,
    super.causeStackTrace,
  ) : super(
          name: 'TraceableException',
          message: message,
        );
}
