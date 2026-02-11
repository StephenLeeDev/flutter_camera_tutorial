import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_camera_tutorial/features/character/data/models/character_model.dart';
import 'package:flutter_camera_tutorial/features/character/domain/usecases/get_character_usecase.dart';
import 'package:flutter_camera_tutorial/features/character/presentation/bloc/character_bloc.dart';
import 'package:flutter_camera_tutorial/features/character/presentation/bloc/character_event.dart';
import 'package:flutter_camera_tutorial/features/character/presentation/bloc/character_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'character_bloc_test.mocks.dart';

// 1. GetCharactersUseCase를 Mocking 하도록 설정
@GenerateMocks([GetCharactersUseCase])
void main() {
  late CharacterBloc characterBloc;
  late MockGetCharactersUseCase mockGetCharactersUseCase;

  setUp(() {
    mockGetCharactersUseCase = MockGetCharactersUseCase();
    characterBloc = CharacterBloc(getCharactersUseCase: mockGetCharactersUseCase);
  });

  // 테스트용 가짜 데이터
  const tCharacterList = CharacterList(results: [
    Character(id: 1, name: 'Rick'),
  ]);

  test('initial state should be CharacterInitial', () {
    // Assert: Bloc의 초기 상태가 CharacterInitial인지 확인
    expect(characterBloc.state, CharacterInitial());
  });

  group('GetCharacterList Event', () {
    // 2. 성공 시나리오 테스트
    blocTest<CharacterBloc, CharacterState>(
      'should emit [CharacterLoading, CharacterLoaded] when data is gotten successfully',
      build: () {
        // Arrange: UseCase가 성공적으로 데이터를 반환하도록 설정
        when(mockGetCharactersUseCase()).thenAnswer((_) async => tCharacterList);
        return characterBloc;
      },
      act: (bloc) => bloc.add(GetCharacterList()), // Act: 이벤트를 추가
      expect: () => <CharacterState>[
        CharacterLoading(), // Assert: 예상되는 상태 순서
        const CharacterLoaded(characterList: tCharacterList),
      ],
    );

    // 3. 실패 시나리오 테스트
    blocTest<CharacterBloc, CharacterState>(
      'should emit [CharacterLoading, CharacterError] when getting data fails',
      build: () {
        // Arrange: UseCase가 Exception을 던지도록 설정
        when(mockGetCharactersUseCase()).thenThrow(Exception('Failed to fetch'));
        return characterBloc;
      },
      act: (bloc) => bloc.add(GetCharacterList()), // Act: 이벤트를 추가
      expect: () => <CharacterState>[
        CharacterLoading(), // Assert: 예상되는 상태 순서
        CharacterError(message: Exception('Failed to fetch').toString()),
      ],
    );
  });
}
