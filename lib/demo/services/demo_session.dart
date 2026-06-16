class DemoSession {
  DemoSession._();

  static bool _isActive = false;

  static bool get isActive => _isActive;

  static void activate() {
    _isActive = true;
  }

  static void deactivate() {
    _isActive = false;
  }
}
