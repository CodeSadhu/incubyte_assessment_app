// String Calculator TDD Kata - Plugin Version
// Can be used as both standalone script and Flutter plugin

import 'dart:io';

import 'package:flutter/material.dart';

/// Exception thrown when negative numbers are passed to the calculator
class NegativeNumberException implements Exception {
  final String message;
  const NegativeNumberException(this.message);

  @override
  String toString() => message;
}

/// String Calculator - Pure function implementation
class StringCalculator {
  /// Adds numbers from a string representation
  ///
  /// Supports:
  /// - Empty strings (returns 0)
  /// - Single numbers
  /// - Comma-separated numbers
  /// - Newline-separated numbers
  /// - Custom delimiters in format "//[delimiter]\n[numbers...]"
  /// - Custom default delimiter (overrides comma default)
  /// - Throws exception for negative numbers
  static int add(String numbers, [String? defaultDelimiter]) {
    if (numbers.isEmpty) {
      return 0;
    }

    final parsedInput = _parseInput(numbers, defaultDelimiter);
    final numberList = _extractNumbers(
      parsedInput.numbers,
      parsedInput.delimiter,
    );

    _validateNoNegatives(numberList);

    return numberList.fold(0, (sum, number) => sum + number);
  }

  /// Safe version that returns a result with error information
  /// Perfect for UI integration where exceptions need to be handled gracefully
  static CalculatorResult calculate(
    String numbers, [
    String? defaultDelimiter,
  ]) {
    try {
      final result = add(numbers, defaultDelimiter);
      return CalculatorResult.success(result);
    } catch (e) {
      return CalculatorResult.error(e.toString());
    }
  }

  /// Parses the input string to extract delimiter and numbers
  static ParsedInput _parseInput(String numbers, [String? defaultDelimiter]) {
    if (numbers.startsWith('//')) {
      final parts = numbers.split('\n');
      final delimiterLine = parts[0];
      final delimiter = delimiterLine.substring(2); // Remove "//"
      final numbersString = parts.sublist(1).join('\n');
      return ParsedInput(delimiter, numbersString);
    }

    return ParsedInput(defaultDelimiter ?? ',', numbers);
  }

  /// Extracts numbers from string using the specified delimiter
  static List<int> _extractNumbers(String numbers, String delimiter) {
    if (numbers.isEmpty) {
      return [];
    }

    // Replace newlines with the delimiter for consistent parsing
    final normalizedNumbers = numbers.replaceAll('\n', delimiter);

    return normalizedNumbers
        .split(delimiter)
        .where((part) => part.isNotEmpty)
        .map((part) => int.parse(part.trim()))
        .toList();
  }

  /// Validates that no negative numbers are present
  static void _validateNoNegatives(List<int> numbers) {
    final negatives = numbers.where((number) => number < 0).toList();

    if (negatives.isNotEmpty) {
      final negativesList = negatives.join(', ');
      throw NegativeNumberException(
        'negative numbers not allowed $negativesList',
      );
    }
  }
}

/// Result wrapper for UI-friendly error handling
class CalculatorResult {
  final int? value;
  final String? error;
  final bool isSuccess;

  CalculatorResult.success(this.value) : error = null, isSuccess = true;

  CalculatorResult.error(this.error) : value = null, isSuccess = false;
}

/// Data class to hold parsed input
class ParsedInput {
  final String delimiter;
  final String numbers;

  const ParsedInput(this.delimiter, this.numbers);
}

// =============================================================================
// TESTS - Only run when used as standalone script
// =============================================================================

class TestResult {
  final String testName;
  final bool passed;
  final String? errorMessage;

  TestResult(this.testName, this.passed, [this.errorMessage]);
}

class TestRunner {
  static final List<TestResult> _results = [];

  static void test(String testName, void Function() testFunction) {
    try {
      testFunction();
      _results.add(TestResult(testName, true));
      debugPrint('✓ $testName');
    } catch (e) {
      _results.add(TestResult(testName, false, e.toString()));
      debugPrint('✗ $testName - $e');
    }
  }

  static void expect(dynamic actual, dynamic expected, [String? message]) {
    if (actual != expected) {
      final msg = message ?? 'Expected $expected, got $actual';
      throw Exception(msg);
    }
  }

  static void expectThrows<T extends Exception>(
    void Function() function,
    String expectedMessage,
  ) {
    try {
      function();
      throw Exception('Expected exception of type $T but none was thrown');
    } catch (e) {
      if (e is! T) {
        throw Exception(
          'Expected exception of type $T but got ${e.runtimeType}',
        );
      }
      if (!e.toString().contains(expectedMessage)) {
        throw Exception(
          'Expected exception message to contain "$expectedMessage" but got "${e.toString()}"',
        );
      }
    }
  }

  static void printSummary() {
    final passed = _results.where((r) => r.passed).length;
    final total = _results.length;

    debugPrint('\n=== Test Summary ===');
    debugPrint('Passed: $passed/$total');

    if (passed == total) {
      debugPrint('🎉 All tests passed!');
    } else {
      debugPrint('❌ Some tests failed:');
      _results.where((r) => !r.passed).forEach((r) {
        debugPrint('  - ${r.testName}: ${r.errorMessage}');
      });
    }
  }
}

// Test Suite - Following TDD progression
void runTests() {
  debugPrint('Running String Calculator TDD Kata Tests...\n');

  // Step 1: Basic functionality tests
  TestRunner.test('empty string returns 0', () {
    TestRunner.expect(StringCalculator.add(''), 0);
  });

  TestRunner.test('single number returns the number', () {
    TestRunner.expect(StringCalculator.add('1'), 1);
    TestRunner.expect(StringCalculator.add('5'), 5);
  });

  TestRunner.test('two comma-separated numbers return their sum', () {
    TestRunner.expect(StringCalculator.add('1,5'), 6);
    TestRunner.expect(StringCalculator.add('2,3'), 5);
  });

  // Step 2: Any amount of numbers
  TestRunner.test('multiple comma-separated numbers return their sum', () {
    TestRunner.expect(StringCalculator.add('1,2,3'), 6);
    TestRunner.expect(StringCalculator.add('1,2,3,4,5'), 15);
    TestRunner.expect(StringCalculator.add('10,20,30'), 60);
  });

  // Step 3: Handle newlines
  TestRunner.test('newlines between numbers work as delimiters', () {
    TestRunner.expect(StringCalculator.add('1\n2,3'), 6);
    TestRunner.expect(StringCalculator.add('1,2\n3'), 6);
    TestRunner.expect(StringCalculator.add('1\n2\n3'), 6);
  });

  // Step 4: Custom delimiters
  TestRunner.test('custom delimiter works', () {
    TestRunner.expect(StringCalculator.add('//;\n1;2'), 3);
    TestRunner.expect(StringCalculator.add('//|\n1|2|3'), 6);
    TestRunner.expect(StringCalculator.add('//*\n1*2*3*4'), 10);
  });

  // Step 5: Negative numbers throw exception
  TestRunner.test('single negative number throws exception', () {
    TestRunner.expectThrows<NegativeNumberException>(
      () => StringCalculator.add('-1'),
      'negative numbers not allowed -1',
    );
  });

  TestRunner.test('negative number with positive numbers throws exception', () {
    TestRunner.expectThrows<NegativeNumberException>(
      () => StringCalculator.add('1,-2,3'),
      'negative numbers not allowed -2',
    );
  });

  // Step 6: Multiple negative numbers in exception
  TestRunner.test('multiple negative numbers show all in exception', () {
    TestRunner.expectThrows<NegativeNumberException>(
      () => StringCalculator.add('-1,2,-3'),
      'negative numbers not allowed -1, -3',
    );
  });

  TestRunner.test('multiple negative numbers with custom delimiter', () {
    TestRunner.expectThrows<NegativeNumberException>(
      () => StringCalculator.add('//;\n-1;2;-3;-4'),
      'negative numbers not allowed -1, -3, -4',
    );
  });

  // Edge cases and additional tests
  TestRunner.test('handles whitespace around numbers', () {
    TestRunner.expect(StringCalculator.add(' 1 , 2 '), 3);
  });

  TestRunner.test('works with zero', () {
    TestRunner.expect(StringCalculator.add('0,1,0'), 1);
    TestRunner.expect(StringCalculator.add('//;\n0;5;0'), 5);
  });

  // Test the UI-friendly calculate method
  TestRunner.test('calculate method returns success result', () {
    final result = StringCalculator.calculate('1,2,3');
    TestRunner.expect(result.isSuccess, true);
    TestRunner.expect(result.value, 6);
    TestRunner.expect(result.error, null);
  });

  TestRunner.test('calculate method returns error result for negatives', () {
    final result = StringCalculator.calculate('-1,2');
    TestRunner.expect(result.isSuccess, false);
    TestRunner.expect(result.value, null);
    TestRunner.expect(
      result.error!.contains('negative numbers not allowed'),
      true,
    );
  });

  TestRunner.printSummary();
}

// =============================================================================
// MAIN - Only runs when used as standalone script
// =============================================================================

void main(List<String> args) {
  // Check if running as standalone script (when args are passed or when run directly)
  if (args.isNotEmpty ||
      Platform.script.path.contains('string_calculator.dart')) {
    debugPrint('String Calculator TDD Kata - Standalone Mode');
    debugPrint('=' * 50);

    // Run all tests
    runTests();

    debugPrint('\n${'=' * 50}');
    debugPrint('Interactive Demo:');

    // Demonstrate the calculator
    final examples = [
      '',
      '1',
      '1,5',
      '1,2,3,4,5',
      '1\n2,3',
      '//;\n1;2;3',
      '//*\n1*2*3*4*5',
    ];

    for (final example in examples) {
      final result = StringCalculator.calculate(example);
      final displayInput = example.replaceAll('\n', '\\n');

      if (result.isSuccess) {
        debugPrint('add("$displayInput") = ${result.value}');
      } else {
        debugPrint('add("$displayInput") error: ${result.error}');
      }
    }

    // Demonstrate negative number exceptions
    debugPrint('\nNegative number examples:');
    final negativeExamples = ['-1', '1,-2,3', '-1,2,-3,-4'];

    for (final example in negativeExamples) {
      final result = StringCalculator.calculate(example);
      debugPrint('add("$example") error: ${result.error}');
    }

    // Demonstrate custom default delimiter
    debugPrint('\nCustom default delimiter examples:');
    final customDelimiterExamples = [
      ('1;2;3', ';'),
      ('1|2|3', '|'),
      ('1*2*3', '*'),
    ];

    for (final example in customDelimiterExamples) {
      final result = StringCalculator.calculate(example.$1, example.$2);
      debugPrint('add("${example.$1}", "${example.$2}") = ${result.value}');
    }
  }
}
