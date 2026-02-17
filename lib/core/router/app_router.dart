import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/character/presentation/bloc/character_bloc.dart';
import '../../features/character/presentation/pages/character_page.dart';
import '../../features/counter/presentation/pages/counter_page.dart';
import '../di/service_locator.dart';
import 'main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // 첫 번째 탭 (Counter)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const CounterPage(),
            ),
          ],
        ),
        // 두 번째 탭 (Character)
        StatefulShellBranch(
          routes: [
            // 1. 파라미터가 없는 기본 경로를 추가합니다.
            GoRoute(
              path: '/character',
              // 2. 이 경로로 오면 기본 레벨인 '1'로 리다이렉트합니다.
              redirect: (context, state) => '/character/1',
            ),
            // 3. 기존의 파라미터가 있는 경로는 그대로 둡니다.
            GoRoute(
              path: '/character/:level',
              builder: (context, state) {
                final level = state.pathParameters['level'] ?? '1'; // 안전장치
                return BlocProvider(
                  create: (context) => CharacterBloc(
                    getCharactersUseCase: locator(),
                  ),
                  child: CharacterPage(level: level),
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
