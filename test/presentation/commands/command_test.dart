import 'package:flutter_test/flutter_test.dart';
import 'package:planning_poker/presentation/commands/command.dart';

void main() {
  group('ObservableCommand', () {
    test('should have initial state', () {
      final command = ObservableCommand<int>(() async => 42);

      expect(command.isLoading, isFalse);
      expect(command.error, isNull);
      expect(command.result, isNull);
      expect(command.hasError, isFalse);
    });

    test('should set isLoading to true during execution', () async {
      var loadingDuringExecution = false;

      final command = ObservableCommand<int>(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 42;
      });

      command.addListener(() {
        if (command.isLoading && command.result == null) {
          loadingDuringExecution = true;
        }
      });

      await command.execute();

      expect(loadingDuringExecution, isTrue);
    });

    test('should return result on success', () async {
      final command = ObservableCommand<int>(() async => 42);

      final result = await command.execute();

      expect(result, equals(42));
      expect(command.result, equals(42));
      expect(command.isLoading, isFalse);
      expect(command.hasError, isFalse);
    });

    test('should set error on failure', () async {
      final command = ObservableCommand<int>(() async {
        throw Exception('Test error');
      });

      final result = await command.execute();

      expect(result, isNull);
      expect(command.hasError, isTrue);
      expect(command.error, contains('Test error'));
      expect(command.isLoading, isFalse);
    });

    test('should clear error', () async {
      final command = ObservableCommand<int>(() async {
        throw Exception('Test error');
      });

      await command.execute();
      expect(command.hasError, isTrue);

      command.clearError();

      expect(command.hasError, isFalse);
      expect(command.error, isNull);
    });

    test('should notify listeners during execution', () async {
      var notificationCount = 0;

      final command = ObservableCommand<int>(() async => 42);

      command.addListener(() {
        notificationCount++;
      });

      await command.execute();

      // Should notify at least twice: when starting (loading=true) and when done
      expect(notificationCount, greaterThanOrEqualTo(2));
    });

    test('should handle async action with delay', () async {
      final command = ObservableCommand<String>(() async {
        await Future.delayed(const Duration(milliseconds: 50));
        return 'delayed result';
      });

      final result = await command.execute();

      expect(result, equals('delayed result'));
    });

    test('should preserve result after multiple calls', () async {
      var callCount = 0;
      final command = ObservableCommand<int>(() async {
        callCount++;
        return callCount;
      });

      await command.execute();
      expect(command.result, equals(1));

      await command.execute();
      expect(command.result, equals(2));
    });

    test('should clear error before new execution', () async {
      var shouldFail = true;
      final command = ObservableCommand<int>(() async {
        if (shouldFail) {
          throw Exception('Error');
        }
        return 42;
      });

      await command.execute();
      expect(command.hasError, isTrue);

      shouldFail = false;
      var errorWasCleared = false;

      command.addListener(() {
        if (command.isLoading && command.error == null) {
          errorWasCleared = true;
        }
      });

      await command.execute();

      expect(errorWasCleared, isTrue);
      expect(command.hasError, isFalse);
      expect(command.result, equals(42));
    });

    test('should work with void return type', () async {
      var executed = false;
      final command = ObservableCommand<void>(() async {
        executed = true;
      });

      await command.execute();

      expect(executed, isTrue);
      expect(command.isLoading, isFalse);
      expect(command.hasError, isFalse);
    });

    test('should work with complex return types', () async {
      final command = ObservableCommand<Map<String, int>>(() async {
        return {'a': 1, 'b': 2};
      });

      await command.execute();

      expect(command.result, equals({'a': 1, 'b': 2}));
    });
  });
}
