import 'package:flutter_test/flutter_test.dart';
import 'package:planning_poker/core/result/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should create success result with data', () {
        final result = Result<String>.success('test data');

        expect(result, isA<Success<String>>());
      });

      test('should return data in when callback', () {
        final result = Result<String>.success('test data');

        final value = result.when(
          success: (data) => data,
          failure: (message) => 'failed',
        );

        expect(value, equals('test data'));
      });

      test('should expose data property', () {
        final result = Success<int>(42);

        expect(result.data, equals(42));
      });

      test('should work with null data', () {
        final result = Result<void>.success(null);

        final value = result.when(
          success: (_) => 'success',
          failure: (message) => 'failed',
        );

        expect(value, equals('success'));
      });

      test('should work with complex types', () {
        final map = {'key': 'value'};
        final result = Result<Map<String, String>>.success(map);

        final value = result.when(
          success: (data) => data['key'],
          failure: (message) => null,
        );

        expect(value, equals('value'));
      });
    });

    group('Failure', () {
      test('should create failure result with message', () {
        final result = Result<String>.failure('error message');

        expect(result, isA<Failure<String>>());
      });

      test('should return message in when callback', () {
        final result = Result<String>.failure('error message');

        final value = result.when(
          success: (data) => 'success',
          failure: (message) => message,
        );

        expect(value, equals('error message'));
      });

      test('should expose message property', () {
        final result = Failure<int>('test error');

        expect(result.message, equals('test error'));
      });

      test('should work with empty message', () {
        final result = Result<String>.failure('');

        final value = result.when(
          success: (data) => 'success',
          failure: (message) => message.isEmpty ? 'empty error' : message,
        );

        expect(value, equals('empty error'));
      });
    });

    group('when method', () {
      test('should transform result type', () {
        final successResult = Result<int>.success(10);
        final failureResult = Result<int>.failure('error');

        final successValue = successResult.when(
          success: (data) => data * 2,
          failure: (message) => -1,
        );

        final failureValue = failureResult.when(
          success: (data) => data * 2,
          failure: (message) => -1,
        );

        expect(successValue, equals(20));
        expect(failureValue, equals(-1));
      });
    });
  });
}
