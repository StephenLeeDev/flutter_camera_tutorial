import '../../domain/repositories/character_repository.dart';
import '../models/character_model.dart';
import '../datasources/character_remote_data_source.dart';

// Domain 계층의 추상 클래스를 구체적으로 구현하는 클래스입니다.
class CharacterRepositoryImpl implements CharacterRepository {
  final CharacterRemoteDataSource remoteDataSource;

  CharacterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CharacterList> getCharacters() async {
    // 데이터 소스를 호출하여 데이터를 가져옵니다.
    // 이 예제에서는 Model과 Entity가 동일하여 별도의 변환이 필요 없지만,
    // 필요하다면 여기서 Model을 Entity로 변환하는 작업을 수행합니다.
    return await remoteDataSource.getCharacters();
  }
}