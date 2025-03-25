
class TapHandlerClass {

  TapHandlerClass._();

  static final instance = TapHandlerClass._();

  final tapTimeout = const Duration(milliseconds: 500);

  // changing variable
  int lastTappedIndex = -1;
  DateTime lastTapTime = DateTime.now();

  init() {
    lastTapTime = DateTime.now();
  }

  bool onTap(int index) {
    final now = DateTime.now();

    if (index != lastTappedIndex && now.difference(lastTapTime) > tapTimeout) {
      lastTappedIndex = index;
      lastTapTime = now;

      // change back to initial value
      lastTappedIndex = -1;
      return true;
    }
    return false;
  }
}