import 'package:go_router/go_router.dart';

import 'screens/calculator_screen.dart';
import 'screens/converter_screen.dart';
import 'screens/home_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/result_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/calculator',
      builder: (context, state) => const CalculatorScreen(),
      routes: [
        // Вложенный маршрут: итоговый адрес — /calculator/result
        GoRoute(
          path: 'result',
          builder: (context, state) {
            final q = state.uri.queryParameters;
            return ResultScreen(
              title: 'Результат вычисления',
              expression: '${q['a']} ${q['op']} ${q['b']}',
              rawQuery: q,
              backPath: '/calculator',
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/converter',
      builder: (context, state) => const ConverterScreen(),
      routes: [
        // Итоговый адрес — /converter/result?amount&from&to
        GoRoute(
          path: 'result',
          builder: (context, state) {
            final q = state.uri.queryParameters;
            return ResultScreen(
              title: 'Результат конвертации',
              expression: '${q['amount']} ${q['from']} → ${q['to']}',
              rawQuery: q,
              backPath: '/converter',
            );
          },
        ),
      ],
    ),
  ],
  // Аналог страницы 404: сюда попадают все неизвестные адреса
  errorBuilder: (context, state) =>
      NotFoundScreen(location: state.uri.toString()),
);
