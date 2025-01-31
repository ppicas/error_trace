import 'package:error_trace/error_trace.dart';
import 'package:test/test.dart';

void main() {
  final fakeST = StackTrace.fromString(
    '#0      main (file:///test.dart:1:1)\n'
    '#1      _rootRun (dart:async/zone.dart:1399:13)\n',
  );

  group('formatError', () {
    test(
      'Should not add the cause '
      'when the exception doesn\'t implement `Traceable`',
      () {
        final error = _Error('Error');

        final text = formatError(error, fakeST);

        expect(
          text,
          'Error\n'
          '  /test.dart 1:1  main',
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

        final text = formatError(error3, fakeST);

        expect(
          text,
          'Error 3 (Caused by: Error 2 (Caused by: Error 1))\n'
          '  /test.dart 1:1  main\n'
          'Caused by: Error 2 (Caused by: Error 1)\n'
          '  /test.dart 1:1  main\n'
          'Caused by: Error 1\n'
          '  /test.dart 1:1  main',
        );
      },
    );

    test(
      'Should add "unknown location" '
      'when the StackTrace is empty',
      () {
        final error = _Error('Error');

        final text = formatError(error, StackTrace.empty);

        expect(
          text,
          'Error\n'
          '  unknown location',
        );
      },
    );

    test(
      'Should use the `Error.stackTrace` '
      'when the StackTrace is empty',
      () {
        final error = _Error('Error', fakeST);

        final text = formatError(error, StackTrace.empty);

        expect(
          text,
          'Error\n'
          '  /test.dart 1:1  main',
        );
      },
    );

    test(
      'Should not filter Dart code lines from the StackTrace '
      'when terse parameter is false',
      () {
        final error = _Error('Error');

        final text = formatError(error, fakeST, terse: false);

        expect(
          text,
          'Error\n'
          '  /test.dart 1:1                main\n'
          '  dart:async/zone.dart 1399:13  _rootRun',
        );
      },
    );
  });
}

class _Error extends Error {
  _Error(this.message, [this.stackTrace]);

  final String message;

  @override
  final StackTrace? stackTrace;

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
