import 'package:calc_web/main.dart';
import 'package:calc_web/router.dart';
import 'package:calc_web/screens/home_screen.dart';
import 'package:calc_web/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appRouter.go('/');
  });

  Future<AppSettings> pumpApp(WidgetTester tester) async {
    final settings = await AppSettings.load();
    await tester.pumpWidget(CalcApp(settings: settings));
    await tester.pumpAndSettle();
    return settings;
  }

  testWidgets('пустая и нечисловая форма калькулятора не уходят с экрана', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Калькулятор'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Вычислить'));
    await tester.pumpAndSettle();

    expect(find.text('Введите число'), findsNWidgets(2));
    expect(appRouter.state.uri.path, '/calculator');

    await tester.enterText(find.byType(TextFormField).at(0), 'abc');
    await tester.enterText(find.byType(TextFormField).at(1), '2');
    await tester.tap(find.text('Вычислить'));
    await tester.pumpAndSettle();

    expect(find.text('Это не число'), findsOneWidget);
    expect(appRouter.state.uri.path, '/calculator');
  });

  testWidgets('калькулятор кладёт операнды в адрес и показывает округление', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Калькулятор'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '1,5');
    await tester.enterText(find.byType(TextFormField).at(1), '2,5');
    await tester.tap(find.text('Вычислить'));
    await tester.pumpAndSettle();

    expect(appRouter.state.uri.path, '/calculator/result');
    expect(appRouter.state.uri.queryParameters['a'], '1.5');
    expect(appRouter.state.uri.queryParameters['op'], '+');
    expect(appRouter.state.uri.queryParameters['b'], '2.5');
    expect(appRouter.state.uri.toString(), contains('op=%2B'));
    expect(find.text('4'), findsOneWidget);
    expect(find.text('1.5 + 2.5'), findsOneWidget);

    await tester.tap(find.text('Вернуться к форме'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, '/calculator');
  });

  testWidgets('прямой адрес результата разбирает ошибки', (tester) async {
    await pumpApp(tester);

    appRouter.go('/calculator/result?a=10&op=%2F&b=3');
    await tester.pumpAndSettle();
    expect(find.text('3.333333'), findsOneWidget);
    expect(find.text('10 / 3'), findsOneWidget);

    appRouter.go('/calculator/result?a=1&op=%2F&b=0');
    await tester.pumpAndSettle();
    expect(find.text('Деление на ноль невозможно'), findsOneWidget);

    appRouter.go('/calculator/result?a=нет&op=%2B&b=1');
    await tester.pumpAndSettle();
    expect(find.text('В адресе переданы не числа'), findsOneWidget);

    appRouter.go('/calculator/result?a=1&op=%5E&b=2');
    await tester.pumpAndSettle();
    expect(find.text('Неизвестная операция'), findsOneWidget);

    appRouter.go('/calculator/result');
    await tester.pumpAndSettle();
    expect(
      find.text('В адресе отсутствует обязательный параметр'),
      findsOneWidget,
    );
  });

  testWidgets('конвертер считает по константам и помнит пару валют', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'currency_from': 'EUR',
      'currency_to': 'USD',
    });
    await pumpApp(tester);
    await tester.tap(find.text('Конвертер валют'));
    await tester.pumpAndSettle();

    expect(find.text('EUR — Евро'), findsOneWidget);
    expect(find.text('USD — Доллар США'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '2');
    await tester.tap(find.text('Конвертировать'));
    await tester.pumpAndSettle();

    expect(appRouter.state.uri.queryParameters['from'], 'EUR');
    expect(appRouter.state.uri.queryParameters['to'], 'USD');
    expect(appRouter.state.uri.queryParameters['amount'], '2');
    // 2 евро = 200 рублей = 200 / 90 доллара.
    expect(find.text('2.222222 USD'), findsOneWidget);

    appRouter.go('/');
    await tester.pumpAndSettle();
    appRouter.go('/converter');
    await tester.pumpAndSettle();
    expect(find.text('EUR — Евро'), findsOneWidget);
    expect(find.text('USD — Доллар США'), findsOneWidget);
  });

  testWidgets('пустая сумма конвертера не открывает результат', (tester) async {
    await pumpApp(tester);
    appRouter.go('/converter');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Конвертировать'));
    await tester.pumpAndSettle();
    expect(find.text('Введите сумму'), findsOneWidget);
    expect(appRouter.state.uri.path, '/converter');
  });

  testWidgets('неизвестный адрес открывает 404', (tester) async {
    await pumpApp(tester);
    appRouter.go('/qwerty');
    await tester.pumpAndSettle();
    expect(find.text('Такой страницы нет'), findsOneWidget);
    expect(find.textContaining('/qwerty'), findsOneWidget);

    await tester.tap(find.text('На главную'));
    await tester.pumpAndSettle();
    expect(find.text('Калькулятор'), findsOneWidget);
  });

  testWidgets('тема сохраняется и переживает новую загрузку', (tester) async {
    final settings = await pumpApp(tester);
    expect(settings.isDark, isFalse);

    await tester.tap(find.byTooltip('Тёмная тема'));
    await tester.pumpAndSettle();

    final reloaded = await AppSettings.load();
    expect(reloaded.isDark, isTrue);

    await tester.pumpWidget(CalcApp(settings: reloaded));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(HomeScreen));
    expect(Theme.of(context).brightness, Brightness.dark);

    await tester.tap(find.byTooltip('Светлая тема'));
    await tester.pumpAndSettle();
    expect(reloaded.isDark, isFalse);
  });

  testWidgets('экраны не переполняются на 360 и 1920', (tester) async {
    await pumpApp(tester);
    const sizes = [Size(360, 740), Size(1920, 1080)];
    const locations = [
      '/',
      '/calculator',
      '/converter',
      '/calculator/result?a=10&op=%2F&b=3',
      '/calculator/result?a=1&op=%2F&b=0',
      '/qwerty',
    ];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      for (final location in locations) {
        appRouter.go(location);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
