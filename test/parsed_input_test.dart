import 'package:flutter_test/flutter_test.dart';
import 'package:incubyte_string_calculator/string_calculator.dart';

void main() {
  group('ParsedInput - Data Class', () {
    test('should create ParsedInput with delimiter and numbers', () {
      const parsedInput = ParsedInput(',', '1,2,3');

      expect(parsedInput.delimiter, equals(','));
      expect(parsedInput.numbers, equals('1,2,3'));
    });

    test('should create ParsedInput with custom delimiter', () {
      const parsedInput = ParsedInput(';', '1;2;3');

      expect(parsedInput.delimiter, equals(';'));
      expect(parsedInput.numbers, equals('1;2;3'));
    });

    test('should create ParsedInput with empty numbers', () {
      const parsedInput = ParsedInput('|', '');

      expect(parsedInput.delimiter, equals('|'));
      expect(parsedInput.numbers, equals(''));
    });

    test('should create ParsedInput with special characters as delimiter', () {
      const parsedInput = ParsedInput('*', '1*2*3');

      expect(parsedInput.delimiter, equals('*'));
      expect(parsedInput.numbers, equals('1*2*3'));
    });
  });

  group('NegativeNumberException - Exception Class', () {
    test('should create exception with message', () {
      const exception = NegativeNumberException('Test message');

      expect(exception.message, equals('Test message'));
      expect(exception.toString(), equals('Test message'));
    });

    test('should create exception with negative numbers message', () {
      const exception = NegativeNumberException(
        'negative numbers not allowed -1, -3',
      );

      expect(exception.message, equals('negative numbers not allowed -1, -3'));
      expect(
        exception.toString(),
        equals('negative numbers not allowed -1, -3'),
      );
    });

    test('should be caught as Exception type', () {
      void throwNegativeException() {
        throw const NegativeNumberException('test');
      }

      expect(throwNegativeException, throwsA(isA<Exception>()));
      expect(throwNegativeException, throwsA(isA<NegativeNumberException>()));
    });
  });

  group('Internal Parsing Logic Tests', () {
    // These tests verify the internal parsing behavior indirectly through public API

    test('should parse comma-separated input correctly', () {
      // Test that comma parsing works as expected
      expect(StringCalculator.add('1,2,3'), equals(6));
      expect(StringCalculator.add('10,20,30'), equals(60));
    });

    test('should parse custom delimiter input correctly', () {
      // Test that custom delimiter parsing works
      expect(StringCalculator.add('//;\n1;2;3'), equals(6));
      expect(StringCalculator.add('//|\n5|10|15'), equals(30));
    });

    test('should parse mixed newline and delimiter input correctly', () {
      // Test that newline replacement works
      expect(StringCalculator.add('1\n2,3'), equals(6));
      expect(StringCalculator.add('1,2\n3,4'), equals(10));
    });

    test('should handle whitespace in parsing', () {
      // Test that whitespace trimming works
      expect(StringCalculator.add(' 1 , 2 , 3 '), equals(6));
      expect(StringCalculator.add('//;\n 1 ; 2 ; 3 '), equals(6));
    });

    test('should handle empty parts in parsing', () {
      // Test that empty parts are filtered out
      expect(StringCalculator.add('1,,3'), equals(4));
      expect(StringCalculator.add('//;\n1;;3'), equals(4));
      expect(StringCalculator.add('1,\n,3'), equals(4));
    });

    test('should parse with custom default delimiter', () {
      // Test custom default delimiter parsing
      expect(StringCalculator.add('1;2;3', ';'), equals(6));
      expect(StringCalculator.add('1|2|3', '|'), equals(6));
      expect(StringCalculator.add('1*2*3', '*'), equals(6));
    });

    test('should prioritize explicit custom delimiter', () {
      // Test that explicit custom delimiter overrides default
      expect(StringCalculator.add('//;\n1;2;3', '*'), equals(6));
      expect(StringCalculator.add('//*\n1*2*3', ';'), equals(6));
    });

    test('should handle complex parsing scenarios', () {
      // Test complex combinations
      expect(StringCalculator.add('//;\n1;2\n3;4', '*'), equals(10));
      expect(StringCalculator.add('1\n2;3', ';'), equals(6));
    });
  });

  group('Validation Logic Tests', () {
    test('should validate and reject single negative', () {
      expect(
        () => StringCalculator.add('-5'),
        throwsA(isA<NegativeNumberException>()),
      );
    });

    test('should validate and reject multiple negatives', () {
      expect(
        () => StringCalculator.add('-1,-2,-3'),
        throwsA(
          isA<NegativeNumberException>().having(
            (e) => e.message,
            'message',
            contains('-1, -2, -3'),
          ),
        ),
      );
    });

    test('should validate with custom delimiters', () {
      expect(
        () => StringCalculator.add('//;\n-1;-2', ';'),
        throwsA(
          isA<NegativeNumberException>().having(
            (e) => e.message,
            'message',
            contains('-1, -2'),
          ),
        ),
      );
    });

    test('should pass validation for valid numbers', () {
      expect(() => StringCalculator.add('1,2,3'), returnsNormally);
      expect(() => StringCalculator.add('0,1,2'), returnsNormally);
      expect(() => StringCalculator.add('//;\n1;2;3'), returnsNormally);
    });
  });
}
