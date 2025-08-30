import 'package:flutter/material.dart';

class NegativeNumberException implements Exception {
  final String message;
  const NegativeNumberException(this.message);

  @override
  String toString() => message;
}

class StringCalculator {
  static int add(String numbers, [String? defaultDelimiter]) {
    if (numbers.isEmpty) return 0;
    final parsedInput = _parseInput(numbers, defaultDelimiter);
    final numberList = _extractNumbers(
      parsedInput.numbers,
      parsedInput.delimiter,
    );
    _validateNoNegatives(numberList);
    return numberList.fold(0, (sum, number) => sum + number);
  }

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

  static ParsedInput _parseInput(String numbers, [String? defaultDelimiter]) {
    if (numbers.startsWith('//')) {
      final parts = numbers.split('\n');
      final delimiterLine = parts[0];
      final delimiter = delimiterLine.substring(2);
      final numbersString = parts.sublist(1).join('\n');
      return ParsedInput(delimiter, numbersString);
    }
    return ParsedInput(defaultDelimiter ?? ',', numbers);
  }

  static List<int> _extractNumbers(String numbers, String delimiter) {
    if (numbers.isEmpty) return [];
    final normalizedNumbers = numbers.replaceAll('\n', delimiter);
    return normalizedNumbers
        .split(delimiter)
        .where((part) => part.isNotEmpty)
        .map((part) => int.parse(part.trim()))
        .toList();
  }

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

class CalculatorResult {
  final int? value;
  final String? error;
  final bool isSuccess;

  CalculatorResult.success(this.value) : error = null, isSuccess = true;
  CalculatorResult.error(this.error) : value = null, isSuccess = false;
}

class ParsedInput {
  final String delimiter;
  final String numbers;
  const ParsedInput(this.delimiter, this.numbers);
}

void main() {
  debugPrint('String Calculator Demo');
  debugPrint('=' * 50);

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

  debugPrint('\nNegative number examples:');
  final negativeExamples = ['-1', '1,-2,3', '-1,2,-3,-4'];
  for (final example in negativeExamples) {
    final result = StringCalculator.calculate(example);
    debugPrint('add("$example") error: ${result.error}');
  }

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
