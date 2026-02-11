import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/character/presentation/bloc/character_bloc.dart';
import '../../features/character/presentation/pages/character_page.dart';
import '../../features/counter/presentation/pages/counter_page.dart';
import '../di/service_locator.dart';

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
        return BlocProvider(
          create: (context) => CharacterBloc(
            // 서비스 로케이터에서 GetCharactersUseCase의 싱글톤 인스턴스를 가져옵니다.
            getCharactersUseCase: locator(),
          ),
          child: CharacterPage(level: level),
        );
      },
    ),
  ],
);