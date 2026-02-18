import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/camera/presentation/bloc/camera_bloc.dart';
import '../../features/camera/presentation/pages/camera_page.dart';
import '../../features/character/presentation/bloc/character_bloc.dart';
import '../../features/character/presentation/pages/character_page.dart';
import '../../features/counter/presentation/pages/counter_page.dart';
import '../di/service_locator.dart';
import 'main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // 1. 바텀 네비게이션이 있는 셸 라우트입니다.
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
            GoRoute(
              path: '/character',
              redirect: (context, state) => '/character/1',
            ),
            GoRoute(
              path: '/character/:level',
              builder: (context, state) {
                final level = state.pathParameters['level'] ?? '1';
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
    // 2. 바텀 네비게이션이 없는 독립적인 카메라 페이지 라우트입니다.
    GoRoute(
      path: '/camera',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => CameraBloc(),
          child: const CameraPage(),
        );
      },
    ),
  ],
);
