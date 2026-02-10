import 'package:equatable/equatable.dart';

import '../../data/character_model.dart';

sealed class CharacterState extends Equatable {
  const CharacterState();

  @override
  List<Object?> get props => [];
}

final class CharacterInitial extends CharacterState {}

final class CharacterLoading extends CharacterState {}

final class CharacterLoaded extends CharacterState {
  final CharacterList characterList;

  const CharacterLoaded({required this.characterList});

  @override
  List<Object?> get props => [characterList];
}

final class CharacterError extends CharacterState {
  final String message;

  const CharacterError({required this.message});

  @override
  List<Object?> get props => [message];
}