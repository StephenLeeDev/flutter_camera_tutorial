import 'package:equatable/equatable.dart';

import '../../data/models/character_model.dart';

abstract class CharacterState extends Equatable {
  const CharacterState();

  @override
  List<Object> get props => [];
}

class CharacterInitial extends CharacterState {}

class CharacterLoading extends CharacterState {}

class CharacterLoaded extends CharacterState {
  final CharacterList characterList;

  const CharacterLoaded({required this.characterList});

  @override
  List<Object> get props => [characterList];
}

class CharacterError extends CharacterState {
  final String message;

  const CharacterError({required this.message});

  @override
  List<Object> get props => [message];
}