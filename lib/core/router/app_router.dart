import 'package:go_router/go_router.dart';

import '../../../features/character/presentation/pages/character_page.dart';
import '../../../features/counter/presentation/pages/counter_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CounterPage(),
    ),
    GoRoute(
      path: '/character/:level',
      builder: (context, state) {
        final level = state.pathParameters['level'] ?? '';
        return CharacterPage(level: level);
      },
    ),
  ],
);