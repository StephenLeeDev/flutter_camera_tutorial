import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/character_bloc.dart';
import '../bloc/character_event.dart';
import '../bloc/character_state.dart';

class CharacterPage extends StatefulWidget {
  final String level;

  const CharacterPage({super.key, required this.level});

  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  @override
  void initState() {
    super.initState();
    // initState에서 GetCharacterList 이벤트를 발생시켜 캐릭터 목록을 가져옵니다.
    context.read<CharacterBloc>().add(GetCharacterList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Character Info")),
      body: BlocBuilder<CharacterBloc, CharacterState>(
        builder: (context, state) {
          if (state is CharacterLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CharacterLoaded) {
            return ListView.builder(
              itemCount: state.characterList.results?.length ?? 0,
              itemBuilder: (context, index) {
                final character = state.characterList.results![index];
                return ListTile(
                  title: Text(character.name ?? 'No name'),
                );
              },
            );
          } else if (state is CharacterError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 100, color: Colors.deepPurple),
                const SizedBox(height: 20),
                Text(
                  "Character Level: ${widget.level}",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text("Back to Counter"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
