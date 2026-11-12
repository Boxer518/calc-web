import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/currency.dart';
import '../settings.dart';
import '../widgets/centered_panel.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _from = 'USD';
  String _to = 'RUB';
  var _restored = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restored) return;
    final settings = SettingsScope.of(context);
    _from = _known(settings.fromCurrency, 'USD');
    _to = _known(settings.toCurrency, 'RUB');
    _restored = true;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _known(String code, String fallback) {
    return currencyByCode(code) == null ? fallback : code;
  }

  String? _amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите сумму';
    if (double.tryParse(value.trim().replaceAll(',', '.')) == null) {
      return 'Это не число';
    }
    return null;
  }

  void _remember(String from, String to) {
    SettingsScope.of(context).saveCurrencyPair(from, to);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = _amountController.text.trim().replaceAll(',', '.');
    _remember(_from, _to);
    context.go(
      '/converter/result?amount=${Uri.encodeComponent(amount)}'
      '&from=${Uri.encodeComponent(_from)}'
      '&to=${Uri.encodeComponent(_to)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Конвертер валют'),
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
                'Курсы заданы константами в коде. Результат откроется '
                'отдельной страницей.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _from,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Из валюты',
                  border: OutlineInputBorder(),
                ),
                items: _currencyItems(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _from = value);
                  _remember(value, _to);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _to,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'В валюту',
                  border: OutlineInputBorder(),
                ),
                items: _currencyItems(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _to = value);
                  _remember(_from, value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Сумма',
                  border: OutlineInputBorder(),
                ),
                validator: _amountValidator,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: const Text('Конвертировать'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _currencyItems() {
    return [
      for (final currency in currencies)
        DropdownMenuItem(
          value: currency.code,
          child: Text(
            '${currency.code} — ${currency.name}',
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ];
  }
}
