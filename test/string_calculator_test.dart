import 'package:flutter_test/flutter_test.dart';
import 'package:incubyte_string_calculator/string_calculator.dart';

void main() {
  group('String Calculator - Basic Functionality', () {
    test('should return 0 for empty string', () {
      expect(StringCalculator.add(''), equals(0));
    });

    test('should return the number for single number string', () {
      expect(StringCalculator.add('1'), equals(1));
      expect(StringCalculator.add('5'), equals(5));
      expect(StringCalculator.add('42'), equals(42));
    });

    test('should return sum for two comma-separated numbers', () {
      expect(StringCalculator.add('1,5'), equals(6));
      expect(StringCalculator.add('2,3'), equals(5));
      expect(StringCalculator.add('10,20'), equals(30));
    });

    test('should handle any amount of comma-separated numbers', () {
      expect(StringCalculator.add('1,2,3'), equals(6));
      expect(StringCalculator.add('1,2,3,4,5'), equals(15));
      expect(StringCalculator.add('10,20,30,40'), equals(100));
      expect(StringCalculator.add('0,0,0,1'), equals(1));
    });
  });

  group('String Calculator - Newline Support', () {
    test('should handle newlines as delimiters', () {
      expect(StringCalculator.add('1\n2,3'), equals(6));
      expect(StringCalculator.add('1,2\n3'), equals(6));
      expect(StringCalculator.add('1\n2\n3'), equals(6));
    });

    test('should handle mixed newlines and commas', () {
      expect(StringCalculator.add('1\n2,3\n4,5'), equals(15));
      expect(StringCalculator.add('10\n20,30\n40'), equals(100));
    });
  });

  group('String Calculator - Custom Delimiters', () {
    test('should handle custom delimiter syntax', () {
      expect(StringCalculator.add('//;\n1;2'), equals(3));
      expect(StringCalculator.add('//|\n1|2|3'), equals(6));
      expect(StringCalculator.add('//*\n1*2*3*4'), equals(10));
      expect(StringCalculator.add('//:\n5:10:15'), equals(30));
    });

    test('should handle custom delimiter with single number', () {
      expect(StringCalculator.add('//;\n5'), equals(5));
      expect(StringCalculator.add('//|\n42'), equals(42));
    });

    test('should handle custom delimiter with empty numbers section', () {
      expect(StringCalculator.add('//;\n'), equals(0));
    });
  });

  group('String Calculator - Default Delimiter Override', () {
    test('should use custom default delimiter', () {
      expect(StringCalculator.add('1;2;3', ';'), equals(6));
      expect(StringCalculator.add('1|2|3', '|'), equals(6));
      expect(StringCalculator.add('1*2*3*4', '*'), equals(10));
      expect(StringCalculator.add('5:10:15', ':'), equals(30));
    });

    test('should prioritize explicit custom delimiter over default', () {
      expect(StringCalculator.add('//;\n1;2;3', '|'), equals(6));
      expect(StringCalculator.add('//*\n1*2*3', ';'), equals(6));
    });

    test('should handle newlines with custom default delimiter', () {
      expect(StringCalculator.add('1\n2;3', ';'), equals(6));
      expect(StringCalculator.add('1;2\n3', ';'), equals(6));
    });
  });

  group('String Calculator - Negative Numbers', () {
    test('should throw exception for single negative number', () {
      expect(
        () => StringCalculator.add('-1'),
        throwsA(
          isA<NegativeNumberException>().having(
            (e) => e.toString(),
            'message',
            contains('negative numbers not allowed -1'),
          ),
        ),
      );
    });

    test('should throw exception for negative number with positives', () {
      expect(
        () => StringCalculator.add('1,-2,3'),
        throwsA(
          isA<NegativeNumberException>().having(
            (e) => e.toString(),
            'message',
            contains('negative numbers not allowed -2'),
          ),
        ),
      );
    });

    test('should show all negative numbers in exception', () {
      expect(
        () => StringCalculator.add('-1,2,-3'),
        throwsA(
          isA<NegativeNumberException>().having(
            (e) => e.toString(),
            'message',
            contains('negative numbers not allowed -1, -3'),
          ),
        ),
      );

      expect(
        () => StringCalculator.add('-1,-2,-3,-4'),
        throwsA(
          isA<NegativeNumberException>().having(
            (e) => e.toString(),
            'message',
            contains('negative numbers not allowed -1, -2, -3, -4'),
          ),
        ),
      );
    });

    test('should handle negatives with custom delimiters', () {
      expect(
        () => StringCalculator.add('//;\n-1;2;-3'),
        throwsA(
          isA<NegativeNumberException>().having(
            (e) => e.toString(),
            'message',
            contains('negative numbers not allowed -1, -3'),
          ),
        ),
      );
    });

    test('should handle negatives with custom default delimiter', () {
      expect(
        () => StringCalculator.add('-1;2;-3', ';'),
        throwsA(
          isA<NegativeNumberException>().having(
            (e) => e.toString(),
            'message',
            contains('negative numbers not allowed -1, -3'),
          ),
        ),
      );
    });
  });

  group('String Calculator - Edge Cases', () {
    test('should handle whitespace around numbers', () {
      expect(StringCalculator.add(' 1 , 2 '), equals(3));
      expect(StringCalculator.add('  5  ,  10  '), equals(15));
    });

    test('should handle zero values', () {
      expect(StringCalculator.add('0,1,0'), equals(1));
      expect(StringCalculator.add('0,0,0'), equals(0));
      expect(StringCalculator.add('//;\n0;5;0'), equals(5));
    });

    test('should handle large numbers', () {
      expect(StringCalculator.add('1000,2000'), equals(3000));
      expect(StringCalculator.add('999999,1'), equals(1000000));
    });

    test('should handle empty parts in delimiter-separated string', () {
      expect(StringCalculator.add('1,,3'), equals(4));
      expect(StringCalculator.add('//;\n1;;3'), equals(4));
    });
  });

  group('String Calculator - Error Cases', () {
    test('should handle invalid number formats gracefully', () {
      expect(
        () => StringCalculator.add('1,abc,3'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => StringCalculator.add('//;\n1;abc;3'),
        throwsA(isA<FormatException>()),
      );
    });

    test('should handle malformed custom delimiter syntax', () {
      expect(() => StringCalculator.add('/\n1,2'), throwsA(isA<Exception>()));
      expect(() => StringCalculator.add('/;1;2'), throwsA(isA<Exception>()));
    });
  });
}
