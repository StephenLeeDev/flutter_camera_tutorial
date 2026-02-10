import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CharacterPage extends StatelessWidget {
  final String level;

  const CharacterPage({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Character Info")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 100, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Text(
              "Character Level: $level",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text("Back to Counter"),
            ),
          ],
        ),
      ),
    );
  }
}