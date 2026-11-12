/// Валюта и её курс к рублю: сколько рублей стоит одна единица.
class Currency {
  const Currency(this.code, this.name, this.rubPerUnit);

  final String code;
  final String name;
  final double rubPerUnit;
}

/// Курсы зафиксированы в коде и не запрашиваются из сети.
const currencies = <Currency>[
  Currency('RUB', 'Российский рубль', 1),
  Currency('USD', 'Доллар США', 90),
  Currency('EUR', 'Евро', 100),
  Currency('CNY', 'Китайский юань', 12.5),
  Currency('GBP', 'Фунт стерлингов', 115),
  Currency('JPY', 'Японская иена', 0.6),
];

Currency? currencyByCode(String? code) {
  if (code == null || code.isEmpty) return null;
  for (final currency in currencies) {
    if (currency.code == code) return currency;
  }
  return null;
}

/// Результат конвертации: либо сумма, либо описание ошибки.
sealed class ConvertResult {
  const ConvertResult();
}

class ConvertSuccess extends ConvertResult {
  const ConvertSuccess(this.value);

  final double value;
}

class ConvertFailure extends ConvertResult {
  const ConvertFailure(this.message);

  final String message;
}

/// Пересчитывает сумму по курсам из [currencies].
///
/// Оба кода и сумма приходят из адреса, поэтому прямой переход по ссылке
/// считается так же, как переход из формы.
ConvertResult convert(String? rawAmount, String? rawFrom, String? rawTo) {
  if (rawAmount == null ||
      rawAmount.trim().isEmpty ||
      rawFrom == null ||
      rawFrom.trim().isEmpty ||
      rawTo == null ||
      rawTo.trim().isEmpty) {
    return const ConvertFailure('В адресе отсутствует обязательный параметр');
  }

  final amount = double.tryParse(rawAmount.trim().replaceAll(',', '.'));
  if (amount == null) {
    return const ConvertFailure('В адресе передана не числовая сумма');
  }

  final from = currencyByCode(rawFrom.trim());
  final to = currencyByCode(rawTo.trim());
  if (from == null || to == null) {
    return const ConvertFailure('Неизвестная валюта');
  }

  final rubles = amount * from.rubPerUnit;
  return ConvertSuccess(rubles / to.rubPerUnit);
}
