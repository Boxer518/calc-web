import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/calculator.dart';
import '../logic/currency.dart';
import '../settings.dart';
import '../widgets/centered_panel.dart';

/// Экран получает числа и операцию только из адреса.
///
/// Прямой переход, обновление страницы и испорченная ссылка разбираются здесь
/// заново: виджет не хранит результат предыдущего экрана.
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    required this.title,
    required this.expression,
    required this.rawQuery,
    required this.backPath,
    super.key,
  });

  final String title;
  final String expression;
  final Map<String, String> rawQuery;
  final String backPath;

  @override
  Widget build(BuildContext context) {
    final isCurrency = backPath == '/converter';
    final String? error;
    final String? valueText;

    if (isCurrency) {
      switch (convert(rawQuery['amount'], rawQuery['from'], rawQuery['to'])) {
        case ConvertSuccess(:final value):
          error = null;
          valueText = '${formatNumber(value)} ${rawQuery['to']}';
        case ConvertFailure(:final message):
          error = message;
          valueText = null;
      }
    } else {
      switch (calculate(rawQuery['a'], rawQuery['op'], rawQuery['b'])) {
        case CalcSuccess(:final value):
          error = null;
          valueText = formatNumber(value);
        case CalcFailure(:final message):
          error = message;
          valueText = null;
      }
    }

    final showExpression = !expression.contains('null');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null) ...[
              Icon(
                Icons.error_outline,
                size: 56,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              if (showExpression) ...[
                Text(
                  expression,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  valueText ?? '',
                  style: theme.textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(backPath),
              child: const Text('Вернуться к форме'),
            ),
          ],
        ),
      ),
    );
  }
}
