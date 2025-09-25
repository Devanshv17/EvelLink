import 'package:evelink/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import '../../utils/utils.dart';
import '../events/all_events_screen.dart';
import '../events/events_screen.dart';
import '../likes/likes_screen.dart';
import '../matches/matches_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AllEventsScreen(),
    const EventsScreen(),
    const LikesScreen(),
    const MatchesScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.celebration_outlined),
      activeIcon: Icon(Icons.celebration),
      label: 'All Events',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.qr_code_scanner),
      label: 'My Event',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.favorite_border),
      activeIcon: Icon(Icons.favorite),
      label: 'Likes',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people_outline),
      activeIcon: Icon(Icons.people),
      label: 'Matches',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
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

