import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../settings.dart';
import '../widgets/centered_panel.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  String _operation = '+';

  static const _operations = ['+', '-', '*', '/'];

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    super.dispose();
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите число';
    if (double.tryParse(value.trim().replaceAll(',', '.')) == null) {
      return 'Это не число';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final a = _aController.text.trim().replaceAll(',', '.');
    final b = _bController.text.trim().replaceAll(',', '.');
    // Аналог redirect после @PostMapping:
    // данные уходят в адрес, а расчёт выполняет экран результата.
    // «+» кодируется: в строке запроса голый плюс означает пробел.
    context.go(
      '/calculator/result?a=${Uri.encodeComponent(a)}'
      '&op=${Uri.encodeComponent(_operation)}'
      '&b=${Uri.encodeComponent(b)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор'),
        actions: [
          IconButton(
            tooltip: 'На главную',
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_outlined),
          ),
          const ThemeModeButton(),
        ],
      ),
      body: CenteredPanel(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Введите два числа. Ответ откроется на отдельном экране.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _aController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Первое число',
                  border: OutlineInputBorder(),
                ),
                validator: _numberValidator,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _operation,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Операция',
                  border: OutlineInputBorder(),
                ),
                items: _operations
                    .map(
                      (operation) => DropdownMenuItem(
                        value: operation,
                        child: Text(operation),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _operation = value ?? '+'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Второе число',
                  border: OutlineInputBorder(),
                ),
                validator: _numberValidator,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: const Text('Вычислить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
