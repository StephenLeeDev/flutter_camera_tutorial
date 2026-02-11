import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../api/dio_client.dart';
import '../../features/character/data/datasources/character_remote_data_source.dart';
import '../../features/character/data/repositories/character_repository_impl.dart';
import '../../features/character/domain/repositories/character_repository.dart';
import '../../features/character/domain/usecases/get_character_usecase.dart';

// GetIt 인스턴스를 생성합니다.
final locator = GetIt.instance;

// 의존성을 등록하는 함수입니다.
void setupLocator() {
  // 외부 서비스 (Dio)
  // dio_client.dart에서 미리 생성된 dio 인스턴스를 등록합니다.
  locator.registerLazySingleton<Dio>(() => dio);

  // 데이터 소스
  locator.registerLazySingleton<CharacterRemoteDataSource>(
        () => CharacterRemoteDataSourceImpl(dio: locator()),
  );

  // 리포지토리
  locator.registerLazySingleton<CharacterRepository>(
        () => CharacterRepositoryImpl(remoteDataSource: locator()),
  );

  // 유즈케이스
  locator.registerLazySingleton(() => GetCharactersUseCase(locator()));
}