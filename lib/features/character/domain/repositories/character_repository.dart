import 'package:flutter_camera_tutorial/features/character/data/models/character_model.dart';

// 데이터 계층에 대한 계약을 정의합니다.
// Domain 계층은 이 추상 클래스에만 의존하며, 구체적인 구현은 알지 못합니다.
abstract class CharacterRepository {
  Future<CharacterList> getCharacters();
}