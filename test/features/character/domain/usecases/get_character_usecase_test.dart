import 'package:flutter_camera_tutorial/features/character/data/models/character_model.dart';
import 'package:flutter_camera_tutorial/features/character/domain/repositories/character_repository.dart';
import 'package:flutter_camera_tutorial/features/character/domain/usecases/get_character_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_character_usecase_test.mocks.dart';

// 1. Mockito에게 CharacterRepository의 Mock 클래스를 생성하도록 요청합니다.
@GenerateMocks([CharacterRepository])
void main() {
  // 테스트에 필요한 객체들을 선언합니다.
  late GetCharactersUseCase useCase;
  late MockCharacterRepository mockCharacterRepository;

  setUp(() {
    // 2. 각 테스트 실행 전에 객체들을 초기화합니다.
    mockCharacterRepository = MockCharacterRepository();
    useCase = GetCharactersUseCase(mockCharacterRepository);
  });

  // 테스트용 가짜 CharacterList 데이터
  const tCharacterList = CharacterList(results: [
    Character(id: 1, name: 'Rick Sanchez', status: 'Alive', species: 'Human', image: 'url1'),
    Character(id: 2, name: 'Morty Smith', status: 'Alive', species: 'Human', image: 'url2'),
  ]);

  test('should get character list from the repository', () async {
    // 3. Arrange: Mock Repository가 특정 동작을 하도록 설정합니다.
    // getCharacters() 메서드가 호출되면, 항상 tCharacterList를 반환하도록 합니다.
    when(mockCharacterRepository.getCharacters())
        .thenAnswer((_) async => tCharacterList);

    // 4. Act: 테스트할 메서드를 실행합니다.
    final result = await useCase();

    // 5. Assert: 결과를 검증합니다.
    // UseCase의 결과가 예상한 tCharacterList와 동일한지 확인합니다.
    expect(result, tCharacterList);
    // Repository의 getCharacters 메서드가 정확히 한 번 호출되었는지 확인합니다.
    verify(mockCharacterRepository.getCharacters());
    // 더 이상 Mock 객체와 상호작용이 없는지 확인합니다.
    verifyNoMoreInteractions(mockCharacterRepository);
  });
}
