import 'dart:async';

import 'package:error_trace/error_trace.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

void main() {
  final containsMain = predicate((StackTrace st) {
    final trace = Trace.from(st);
    return trace.frames
        .any((frame) => frame.member?.startsWith('main.<') ?? false);
  });

  group('FutureErrorUtils', () {
    test(
        'Should ensure `main()` is in the stack trace '
        'when `traceErrors()` is used in a Future '
        'and an asynchronous gap occurs', () async {
      final completer = Completer<StackTrace>();
      unawaited(_asyncFuncThatThrows().traceErrors().catchError((_, st) {
        completer.complete(st);
      }));

      final st = await completer.future;

      expect(st, containsMain);
    });

    test(
        'Should not ensure `main()` is in the stack trace '
        'when `traceErrors()` is not used in a Future '
        'and an asynchronous gap occurs', () async {
      final completer = Completer<StackTrace>();
      unawaited(_asyncFuncThatThrows().catchError((_, st) {
        completer.complete(st);
      }));

      final st = await completer.future;

      expect(st, isNot(containsMain));
    });
  });

  group('StreamErrorUtils', () {
    test(
        'Should ensure `main()` is in the stack trace '
        'when `traceErrors()` is used in a Stream '
        'and an asynchronous gap occurs', () async {
      final completer = Completer<StackTrace>();
      _streamThatThrows().traceErrors().listen(null, onError: (e, st) {
        completer.complete(st);
      });

      final st = await completer.future;

      expect(st, containsMain);
    });

    test(
        'Should not ensure `main()` is in the stack trace '
        'when `traceErrors()` is not used in a Stream '
        'and an asynchronous gap occurs', () async {
      final completer = Completer<StackTrace>();
      _streamThatThrows().listen(null, onError: (e, st) {
        completer.complete(st);
      });

      final st = await completer.future;

      expect(st, isNot(containsMain));
    });
  });
}

Future<void> _asyncFuncThatThrows() async {
  return Future.delayed(Duration.zero).then((value) {
    return Future.error(Exception('Network error'), StackTrace.current);
  });
}

Stream<void> _streamThatThrows() {
  // ignore: discarded_futures
  return Stream.fromFuture(_asyncFuncThatThrows());
}
