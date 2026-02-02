import 'package:flutter_test/flutter_test.dart';
import 'package:planning_poker/core/utils/session_key_generator.dart';

void main() {
  group('SessionKeyGenerator', () {
    test('should generate key with correct length', () {
      final key = SessionKeyGenerator.generate();

      expect(key.length, equals(6));
    });

    test('should generate key with only valid characters', () {
      final key = SessionKeyGenerator.generate();
      final validChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

      for (var char in key.split('')) {
        expect(
          validChars.contains(char),
          isTrue,
          reason: 'Character $char should be valid',
        );
      }
    });

    test('should generate unique keys', () {
      final keys = <String>{};

      for (int i = 0; i < 100; i++) {
        keys.add(SessionKeyGenerator.generate());
      }

      // With 6 characters and 36 possible values, collisions should be extremely rare
      expect(
        keys.length,
        greaterThan(95),
        reason: 'Most keys should be unique',
      );
    });

    test('should generate keys with uppercase letters only', () {
      final key = SessionKeyGenerator.generate();

      expect(key, equals(key.toUpperCase()));
    });

    test('should not contain special characters', () {
      final key = SessionKeyGenerator.generate();
      final specialChars = r'!@#$%^&*()_+-=[]{}|;:,.<>?/~`';

      for (var char in specialChars.split('')) {
        expect(
          key.contains(char),
          isFalse,
          reason: 'Key should not contain special character: $char',
        );
      }
    });

    test('should not contain lowercase letters', () {
      final key = SessionKeyGenerator.generate();
      final lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';

      for (var char in lowercaseChars.split('')) {
        expect(
          key.contains(char),
          isFalse,
          reason: 'Key should not contain lowercase letter: $char',
        );
      }
    });
  });
}
