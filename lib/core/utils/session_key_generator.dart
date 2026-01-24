import 'dart:math';

/// Generates unique session keys for Planning Poker sessions
class SessionKeyGenerator {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const int _keyLength = 6;

  static String generate() {
    final random = Random.secure();
    return List.generate(
      _keyLength,
      (_) => _chars[random.nextInt(_chars.length)],
    ).join();
  }
}
