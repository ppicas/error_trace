import 'package:error_trace/error_trace.dart';
import 'package:test/test.dart';

void main() {
  group('StackTraceExtension', () {
    group('When error Object extends Traceable', () {
      test(
          'Should generate a Chain '
          'including first the cause StackTrace '
          'and then the current one', () async {
        try {
          await _callAndThrowATraceable();
        } catch (e, st) {
          final chain = st.chainCauses(e);

          final flattenedMembers = chain.traces.expand(
            (trace) => trace.frames.map((frame) => frame.member),
          );
          expect(
            flattenedMembers,
            containsAllInOrder([
              'main.fakeSomeNetworkWork.<fn>',
              'main.callAndThrowATraceable.throwFromCall',
              'main.callAndThrowATraceable',
            ]),
          );
        }
      });

      test(
          'Should generate a Chain '
          'first recurrently including in order the causes StackTraces '
          'and then the current one', () async {
        try {
          await _indirectCallAndThrowATraceable();
        } catch (e, st) {
          final chain = st.chainCauses(e);

          final flattenedMembers = chain.traces.expand(
            (trace) => trace.frames.map((frame) => frame.member),
          );
          expect(
            flattenedMembers,
            containsAllInOrder([
              'main.fakeSomeNetworkWork.<fn>',
              'main.callAndThrowATraceable.throwFromCall',
              'main.callAndThrowATraceable',
              'main.indirectCallAndThrowATraceable.throwFromIndirectCall',
              'main.indirectCallAndThrowATraceable',
            ]),
          );
        }
      });
    });

    group('When error Object does not extends Traceable', () {
      test('Should return a Chain with only 1 Trace', () async {
        try {
          await _callAndNotThrowATraceable();
        } catch (e, st) {
          final chain = st.chainCauses(e);
          expect(chain.traces, hasLength(1));
        }
      });
    });
  });
}

Future<void> _fakeSomeNetworkWork() {
  return Future.delayed(Duration.zero, () {
    throw Exception('Network error');
  });
}

Future<void> _callAndThrowATraceable() async {
  Never throwFromCall(Object e, StackTrace st) {
    throw TraceableException(e, st);
  }

  try {
    await _fakeSomeNetworkWork();
  } catch (e, st) {
    throwFromCall(e, st);
  }
}

Future<void> _indirectCallAndThrowATraceable() async {
  Never throwFromIndirectCall(Object e, StackTrace st) {
    throw TraceableException(e, st);
  }

  try {
    await _callAndThrowATraceable();
  } catch (e, st) {
    throwFromIndirectCall(e, st);
  }
}

Future<void> _callAndNotThrowATraceable() async {
  try {
    await _fakeSomeNetworkWork();
  } catch (e) {
    throw Exception('No Traceable exception');
  }
}