/// Результат вычисления: либо значение, либо описание ошибки.
sealed class CalcResult {
  const CalcResult();
}

class CalcSuccess extends CalcResult {
  const CalcSuccess(this.value);

  final double value;
}

class CalcFailure extends CalcResult {
  const CalcFailure(this.message);

  final String message;
}

/// Считает выражение из параметров адреса.
///
/// Пустые и отсутствующие параметры не смешиваются с нечисловым вводом:
/// экран результата должен объяснить, что именно сломано в ссылке.
CalcResult calculate(String? rawA, String? rawOp, String? rawB) {
  if (rawA == null ||
      rawA.trim().isEmpty ||
      rawB == null ||
      rawB.trim().isEmpty ||
      rawOp == null ||
      rawOp.isEmpty) {
    return const CalcFailure('В адресе отсутствует обязательный параметр');
  }

  final a = double.tryParse(rawA.trim().replaceAll(',', '.'));
  final b = double.tryParse(rawB.trim().replaceAll(',', '.'));
  if (a == null || b == null) {
    return const CalcFailure('В адресе переданы не числа');
  }

  return switch (rawOp) {
    '+' => CalcSuccess(a + b),
    '-' => CalcSuccess(a - b),
    '*' => CalcSuccess(a * b),
    '/' => b == 0
        ? const CalcFailure('Деление на ноль невозможно')
        : CalcSuccess(a / b),
    _ => const CalcFailure('Неизвестная операция'),
  };
}

/// Округляет значение до 6 знаков после запятой и убирает хвостовые нули.
///
/// Так 10 / 3 показывается как 3.333333, а не как 3.3333333333333335.
String formatNumber(double value) {
  if (value.isNaN) return 'не число';
  if (value.isInfinite) {
    return value.isNegative ? '−∞' : '∞';
  }

  var text = value.toStringAsFixed(6);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
  }
  if (text == '-0') return '0';
  return text;
}
