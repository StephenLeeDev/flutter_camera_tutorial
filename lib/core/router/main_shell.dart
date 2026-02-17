import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Counter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Character',
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => _onItemTapped(index, context),
      ),
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    // goBranch를 사용하여 해당 인덱스의 탭으로 이동합니다.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
