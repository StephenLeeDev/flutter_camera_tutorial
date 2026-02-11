import 'package:equatable/equatable.dart';

abstract class CharacterEvent extends Equatable {
  const CharacterEvent();

  @override
  List<Object> get props => [];
}

// 캐릭터 목록을 가져오라는 이벤트
class GetCharacterList extends CharacterEvent {}