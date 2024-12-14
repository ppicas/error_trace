import 'package:error_trace/error_trace.dart';
import 'package:test/test.dart';

void main() {
  Future<void> fakeSomeNetworkWork() {
    return Future.delayed(Duration.zero, () {
      throw Exception('Network error');
    });
  }

  Future<void> callAndThrowATraceable() async {
    Never throwFromCall(Object e, StackTrace st) {
      throw TraceableException(e, st);
    }

    try {
      await fakeSomeNetworkWork();
    } catch (e, st) {
      throwFromCall(e, st);
    }
  }

  Future<void> indirectCallAndThrowATraceable() async {
    Never throwFromIndirectCall(Object e, StackTrace st) {
      throw TraceableException(e, st);
    }

    try {
      await callAndThrowATraceable();
    } catch (e, st) {
      throwFromIndirectCall(e, st);
    }
  }

  Future<void> callAndNotThrowATraceable() async {
    try {
      await fakeSomeNetworkWork();
    } catch (e) {
      throw Exception('No Traceable exception');
    }
  }

  group('StackTraceExtension', () {
    group('When error Object extends Traceable', () {
      test(
          'Should generate a Chain '
          'including first the cause StackTrace '
          'and then the current one', () async {
        try {
          await callAndThrowATraceable();
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
          await indirectCallAndThrowATraceable();
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
          await callAndNotThrowATraceable();
        } catch (e, st) {
          final chain = st.chainCauses(e);
          expect(chain.traces, hasLength(1));
        }
      });
    });
  });
}
