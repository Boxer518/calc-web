import 'package:calc_web/logic/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('в списке не меньше пяти валют', () {
    expect(currencies.length, greaterThanOrEqualTo(5));
    expect(
      currencies.map((currency) => currency.code),
      containsAll(['RUB', 'USD', 'EUR', 'CNY', 'GBP']),
    );
  });

  test('доллары переводятся в рубли по константе', () {
    final result = convert('2', 'USD', 'RUB');
    expect((result as ConvertSuccess).value, 180);
  });

  test('рубли переводятся в евро', () {
    final result = convert('250', 'RUB', 'EUR');
    expect((result as ConvertSuccess).value, 2.5);
  });

  test('одинаковая валюта возвращает ту же сумму', () {
    final result = convert('15', 'GBP', 'GBP');
    expect((result as ConvertSuccess).value, 15);
  });

  test('запятая в сумме', () {
    final result = convert('1,5', 'EUR', 'RUB');
    expect((result as ConvertSuccess).value, 150);
  });

  test('нечисловая сумма', () {
    final result = convert('много', 'USD', 'EUR');
    expect(result, isA<ConvertFailure>());
    expect(
      (result as ConvertFailure).message,
      'В адресе передана не числовая сумма',
    );
  });

  test('неизвестная валюта', () {
    final result = convert('10', 'USD', 'BTC');
    expect(result, isA<ConvertFailure>());
    expect((result as ConvertFailure).message, 'Неизвестная валюта');
  });

  test('отсутствует обязательный параметр', () {
    final result = convert('10', null, 'RUB');
    expect(result, isA<ConvertFailure>());
    expect(
      (result as ConvertFailure).message,
      'В адресе отсутствует обязательный параметр',
    );
  });
}
