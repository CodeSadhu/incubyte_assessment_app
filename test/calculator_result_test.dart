import 'package:flutter_test/flutter_test.dart';
import 'package:incubyte_string_calculator/string_calculator.dart';

void main() {
  group('CalculatorResult - Success Cases', () {
    test('should create successful result', () {
      final result = CalculatorResult.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.value, equals(42));
      expect(result.error, isNull);
    });

    test('should create successful result with zero', () {
      final result = CalculatorResult.success(0);

      expect(result.isSuccess, isTrue);
      expect(result.value, equals(0));
      expect(result.error, isNull);
    });
  });

  group('CalculatorResult - Error Cases', () {
    test('should create error result', () {
      final result = CalculatorResult.error('Test error message');

      expect(result.isSuccess, isFalse);
      expect(result.value, isNull);
      expect(result.error, equals('Test error message'));
    });

    test('should create error result with empty message', () {
      final result = CalculatorResult.error('');

      expect(result.isSuccess, isFalse);
      expect(result.value, isNull);
      expect(result.error, equals(''));
    });
  });

  group('StringCalculator.calculate() - UI-Safe Method', () {
    test('should return success result for valid input', () {
      final result = StringCalculator.calculate('1,2,3');

      expect(result.isSuccess, isTrue);
      expect(result.value, equals(6));
      expect(result.error, isNull);
    });

    test('should return success result for empty input', () {
      final result = StringCalculator.calculate('');

      expect(result.isSuccess, isTrue);
      expect(result.value, equals(0));
      expect(result.error, isNull);
    });

    test('should return success result with custom delimiter', () {
      final result = StringCalculator.calculate('1;2;3', ';');

      expect(result.isSuccess, isTrue);
      expect(result.value, equals(6));
      expect(result.error, isNull);
    });

    test('should return error result for negative numbers', () {
      final result = StringCalculator.calculate('1,-2,3');

      expect(result.isSuccess, isFalse);
      expect(result.value, isNull);
      expect(result.error, contains('negative numbers not allowed -2'));
    });

    test('should return error result for multiple negatives', () {
      final result = StringCalculator.calculate('-1,2,-3,-4');

      expect(result.isSuccess, isFalse);
      expect(result.value, isNull);
      expect(result.error, contains('negative numbers not allowed -1, -3, -4'));
    });

    test('should return error result for invalid format', () {
      final result = StringCalculator.calculate('1,abc,3');

      expect(result.isSuccess, isFalse);
      expect(result.value, isNull);
      expect(result.error, isNotNull);
    });

    test('should handle custom delimiters with negatives', () {
      final result = StringCalculator.calculate('//;\n-1;2;-3');

      expect(result.isSuccess, isFalse);
      expect(result.value, isNull);
      expect(result.error, contains('negative numbers not allowed -1, -3'));
    });
  });
}
