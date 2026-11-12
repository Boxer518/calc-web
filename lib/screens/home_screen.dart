import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../settings.dart';
import '../widgets/centered_panel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        actions: const [ThemeModeButton()],
      ),
      body: CenteredPanel(
        maxWidth: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Два расчёта, каждый со своим адресом',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Форма только собирает данные. Результат открывается '
              'отдельной страницей, и его можно передать ссылкой.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.go('/calculator'),
                icon: const Icon(Icons.calculate),
                label: const Text('Калькулятор'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.go('/converter'),
                icon: const Icon(Icons.currency_exchange),
                label: const Text('Конвертер валют'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
