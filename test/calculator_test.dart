import 'package:calc_web/logic/calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('сложение', () {
    final result = calculate('2', '+', '3');
    expect(result, isA<CalcSuccess>());
    expect((result as CalcSuccess).value, 5);
  });

  test('вычитание', () {
    final result = calculate('10', '-', '4');
    expect((result as CalcSuccess).value, 6);
  });

  test('умножение', () {
    final result = calculate('6', '*', '7');
    expect((result as CalcSuccess).value, 42);
  });

  test('деление', () {
    final result = calculate('8', '/', '2');
    expect((result as CalcSuccess).value, 4);
  });

  test('деление на ноль', () {
    final result = calculate('1', '/', '0');
    expect(result, isA<CalcFailure>());
    expect(
      (result as CalcFailure).message,
      'Деление на ноль невозможно',
    );
  });

  test('нечисловой ввод', () {
    final result = calculate('abc', '+', '1');
    expect(result, isA<CalcFailure>());
    expect((result as CalcFailure).message, 'В адресе переданы не числа');
  });

  test('отсутствует обязательный параметр', () {
    final result = calculate(null, '+', '1');
    expect(result, isA<CalcFailure>());
    expect(
      (result as CalcFailure).message,
      'В адресе отсутствует обязательный параметр',
    );
  });

  test('неизвестная операция', () {
    final result = calculate('1', '^', '2');
    expect(result, isA<CalcFailure>());
    expect((result as CalcFailure).message, 'Неизвестная операция');
  });

  test('плюс, прочитанный как пробел, не молчит', () {
    final result = calculate('1', ' ', '2');
    expect(result, isA<CalcFailure>());
    expect((result as CalcFailure).message, 'Неизвестная операция');
  });

  test('запятая принимается как десятичный разделитель', () {
    final result = calculate('1,5', '+', '2,25');
    expect((result as CalcSuccess).value, closeTo(3.75, 1e-9));
  });

  test('отрицательные числа', () {
    final result = calculate('-2', '*', '4');
    expect((result as CalcSuccess).value, -8);
  });

  test('деление округляется до разумного числа знаков', () {
    final result = calculate('10', '/', '3');
    final text = formatNumber((result as CalcSuccess).value);
    expect(text, '3.333333');
    expect(text, isNot('3.3333333333333335'));
  });

  test('формат убирает хвост из нулей и двоичный шум', () {
    final sum = calculate('0.1', '+', '0.2');
    expect(formatNumber((sum as CalcSuccess).value), '0.3');
    expect(formatNumber(5), '5');
    expect(formatNumber(-1.5), '-1.5');
    expect(formatNumber(-0.0000001), '0');
  });
}
