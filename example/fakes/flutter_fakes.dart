import 'dart:async';

void runApp(StatefulWidget widget) {
  runZonedGuarded(
    () {
      try {
        widget.init();
        widget.build();
      } catch (error, stack) {
        FlutterError.onError?.call(error, stack);
      }
    },
    (error, stack) {
      PlatformDispatcher.instance.onError?.call(error, stack);
    },
  );
}

abstract class Widget {
  const Widget();
}

abstract class StatefulWidget implements Widget {
  const StatefulWidget();

  void init();

  Widget build();
}

class Text extends Widget {
  const Text(String text);
}

abstract final class WidgetsFlutterBinding {
  static void ensureInitialized() {
    // No op
  }
}

final class PlatformDispatcher {
  static final instance = PlatformDispatcher._();

  PlatformDispatcher._();

  bool Function(Object error, StackTrace stackTrace)? onError;
}

abstract final class FlutterError {
  static void Function(Object error, StackTrace stackTrace)? onError;
}
