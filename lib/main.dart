// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'string_calculator.dart';

void main() {
  runApp(const StringCalculatorApp());
}

class StringCalculatorApp extends StatelessWidget {
  const StringCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'String Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CalculatorHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({super.key});

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _delimiterController = TextEditingController();
  String _result = '';
  bool _isError = false;
  bool _hasCalculated = false;

  int _delimiterChoice = 0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _delimiterController.text = ','; // Default comma
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _delimiterController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _calculate() {
    final input = _textController.text.trim();
    final customDelimiter = _delimiterChoice == 1
        ? _delimiterController.text.trim()
        : null;

    // Update text field delimiter if custom delimiter is being used and text has content
    if (_delimiterChoice == 1 && input.isNotEmpty && !input.startsWith('//')) {
      final currentDelimiter = ','; // Assume current delimiter is comma
      final newDelimiter = _delimiterController.text.trim();
      if (newDelimiter.isNotEmpty && newDelimiter != currentDelimiter) {
        final updatedInput = input.replaceAll(currentDelimiter, newDelimiter);
        _textController.text = updatedInput;
      }
    }

    final result = StringCalculator.calculate(
      _textController.text.trim(),
      customDelimiter,
    );

    setState(() {
      _hasCalculated = true;
      _isError = !result.isSuccess;

      if (result.isSuccess) {
        _result = result.value.toString();
      } else {
        _result = result.error ?? 'Unknown error';
      }
    });

    // Trigger animation
    _animationController.reset();
    _animationController.forward();
  }

  void _clear() {
    setState(() {
      _textController.clear();
      _result = '';
      _isError = false;
      _hasCalculated = false;
    });
    _animationController.reset();
  }

  Widget _buildExampleChips() {
    final delimiter = _delimiterChoice == 1
        ? _delimiterController.text.trim()
        : ',';

    final examples = [
      ('Basic: 1${delimiter}2${delimiter}3', '1${delimiter}2${delimiter}3'),
      ('Newlines: 1\\n2${delimiter}3', '1\n2${delimiter}3'),
      ('Custom: //;\\n1;2', '//;\n1;2'),
    ];

    return Wrap(
      spacing: 8.0,
      children: examples.map((example) {
        return ActionChip(
          label: Text(example.$1, style: const TextStyle(fontSize: 12)),
          onPressed: () {
            _textController.text = example.$2;
          },
          backgroundColor: Colors.deepPurple.withOpacity(0.1),
        );
      }).toList(),
    );
  }

  Widget _buildDelimiterSection() {
    return Card(
      elevation: 2,
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDelimiterHeader(),
            const SizedBox(height: 8),
            _buildDelimiterRadioButtons(),
            if (_delimiterChoice == 1) ...[
              const SizedBox(height: 12),
              _buildDelimiterTextField(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDelimiterHeader() {
    return Row(
      children: [
        Icon(Icons.settings, color: Colors.orange.shade700, size: 18),
        const SizedBox(width: 8),
        Text(
          'Default Delimiter (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.orange.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildDelimiterRadioButtons() {
    return Column(
      children: [
        RadioListTile<int>(
          title: const Text(
            'Use default delimiter (,)',
            style: TextStyle(fontSize: 13),
          ),
          value: 0,
          groupValue: _delimiterChoice,
          onChanged: (value) {
            setState(() {
              _delimiterChoice = value ?? 0;
              if (_delimiterChoice == 0) {
                _delimiterController.text = ',';
              }
            });
          },
          activeColor: Colors.orange,
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<int>(
          title: const Text(
            'Use custom delimiter',
            style: TextStyle(fontSize: 13),
          ),
          value: 1,
          groupValue: _delimiterChoice,
          onChanged: (value) {
            setState(() {
              _delimiterChoice = value ?? 0;
            });
          },
          activeColor: Colors.orange,
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildDelimiterTextField() {
    return TextField(
      controller: _delimiterController,
      decoration: InputDecoration(
        labelText: 'Custom Delimiter',
        hintText: 'e.g., ; or | or *',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(Icons.text_fields, color: Colors.orange.shade600),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      maxLength: 3,
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildInputSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputLabel(),
            const SizedBox(height: 12),
            _buildNumberTextField(),
            const SizedBox(height: 16),
            _buildExampleLabel(),
            const SizedBox(height: 8),
            _buildExampleChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel() {
    return const Text(
      'Enter numbers:',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildNumberTextField() {
    final delimiter = _delimiterChoice == 1
        ? _delimiterController.text.trim()
        : ',';

    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        hintText:
            'e.g., 1${delimiter}2${delimiter}3 or //;\\n1;2 or 1\\n2${delimiter}3',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.calculate),
        suffixIcon: _textController.text.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear), onPressed: _clear)
            : null,
      ),
      maxLines: 3,
      onSubmitted: (_) => _calculate(),
    );
  }

  Widget _buildExampleLabel() {
    return const Text(
      'Quick Examples:',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _calculate,
        icon: const Icon(Icons.play_arrow, size: 28),
        label: const Text(
          'Calculate',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: _hasCalculated
            ? _buildAnimatedResult()
            : _buildPlaceholderResult(),
      ),
    );
  }

  Widget _buildAnimatedResult() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildResultCard(),
          ),
        );
      },
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 8,
      color: _isError ? Colors.red.shade50 : Colors.green.shade50,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResultIcon(),
              const SizedBox(height: 16),
              _buildResultTitle(),
              const SizedBox(height: 8),
              _buildResultValue(),
              if (!_isError && _delimiterChoice == 1) ...[
                const SizedBox(height: 8),
                _buildDelimiterUsedInfo(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultIcon() {
    return Icon(
      _isError ? Icons.error : Icons.check_circle,
      size: 48,
      color: _isError ? Colors.red : Colors.green,
    );
  }

  Widget _buildResultTitle() {
    return Text(
      _isError ? 'Error' : 'Result',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Widget _buildResultValue() {
    return Text(
      _result,
      style: TextStyle(
        fontSize: _isError ? 16 : 36,
        fontWeight: FontWeight.bold,
        color: _isError ? Colors.red.shade800 : Colors.green.shade800,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDelimiterUsedInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Used delimiter: "${_delimiterController.text}"',
        style: TextStyle(
          fontSize: 12,
          color: Colors.green.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPlaceholderResult() {
    return Card(
      elevation: 2,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlaceholderIcon(),
            const SizedBox(height: 16),
            _buildPlaceholderText(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Icon(Icons.calculate_outlined, size: 48, color: Colors.grey);
  }

  Widget _buildPlaceholderText() {
    return const Text(
      'Enter numbers and press Calculate',
      style: TextStyle(fontSize: 16, color: Colors.grey),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoHeader(),
          const SizedBox(height: 8),
          _buildInfoContent(),
        ],
      ),
    );
  }

  Widget _buildInfoHeader() {
    return Row(
      children: [
        Icon(Icons.info, color: Colors.blue.shade700, size: 20),
        const SizedBox(width: 8),
        Text(
          'Supported Formats:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoContent() {
    return Text(
      '• Comma-separated: 1,2,3\n'
      '• Newline-separated: 1\\n2,3\n'
      '• Custom delimiters: //;\\n1;2;3\n'
      '• Custom default delimiter (optional)\n'
      '• Empty string returns 0\n'
      '• Negative numbers throw errors',
      style: TextStyle(fontSize: 13, color: Colors.blue.shade600, height: 1.4),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildInputSection(),
          const SizedBox(height: 16),
          _buildDelimiterSection(),
          const SizedBox(height: 24),
          _buildCalculateButton(),
          const SizedBox(height: 40),
          _buildResultSection(),
          _buildInfoSection(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'String Calculator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: _buildMainContent(),
      resizeToAvoidBottomInset: true,
    );
  }
}
