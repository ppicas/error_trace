abstract final class Firebase {
  static Future<void> initializeApp() async {}
}

final class FirebaseCrashlytics {
  static const instance = FirebaseCrashlytics._();

  const FirebaseCrashlytics._();

  Future<void> recordError(
    Object error,
    StackTrace stack, {
    bool fatal = true,
  }) async {
    print('### Crashlytics recordError ###');
    print('--- error:\n$error');
    print('--- stackTrace:\n$stack');
    print('### End of recordError ###');
  }

  Future<void> recordFlutterFatalError(Object error, StackTrace stack) async {
    print('### Crashlytics recordFlutterFatalError ###');
    print('--- error:\n$error');
    print('--- stackTrace:\n$stack');
    print('### End of recordFlutterFatalError ###');
  }
}
