import 'package:flutter/material.dart';
import '../../utils/utils.dart';
import '../events/events_screen.dart';
import '../likes/likes_screen.dart';
import '../matches/matches_screen.dart';
import '../chat/chat_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const EventsScreen(),
    const LikesScreen(),
    const MatchesScreen(),
    const ChatListScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.qr_code_scanner),
      label: 'Events',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.favorite),
      label: 'Likes',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Matches',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.chat),
      label: 'Chat',
    ),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textSecondary,
        items: _navItems,
      ),
    );
  }
}
