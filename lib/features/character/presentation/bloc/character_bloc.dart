import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_camera_tutorial/features/character/domain/usecases/get_character_usecase.dart';
import 'character_event.dart';
import 'character_state.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final GetCharactersUseCase getCharactersUseCase;

  CharacterBloc({required this.getCharactersUseCase}) : super(CharacterInitial()) {
    on<GetCharacterList>((event, emit) async {
      emit(CharacterLoading());
      try {
        final characterList = await getCharactersUseCase();
        emit(CharacterLoaded(characterList: characterList));
      } catch (e) {
        emit(CharacterError(message: e.toString()));
      }
    });
  }
}