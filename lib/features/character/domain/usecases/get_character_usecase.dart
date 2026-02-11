import '../../data/models/character_model.dart';
import '../repositories/character_repository.dart';

// 애플리케이션의 특정 비즈니스 로직을 캡슐화합니다.
class GetCharactersUseCase {
  final CharacterRepository repository;

  GetCharactersUseCase(this.repository);

  // 클래스를 함수처럼 호출할 수 있게 해주는 `call` 메서드입니다.
  // 파라미터가 필요 없는 경우 비워둡니다.
  Future<CharacterList> call() async {
    return await repository.getCharacters();
  }
}