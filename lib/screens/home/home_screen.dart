import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/likes_provider.dart';
import '../../services/auth_service.dart';
import '../discovery/discovery_screen.dart';
import '../likes/likes_you_screen.dart';
import '../matches/matches_screen.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  final List<Widget> _screens = [
    const DiscoveryScreen(),
    const LikesYouScreen(),
    const MatchesScreen(),
  ];

  void _openQRScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );
  }

  void _signOut() async {
    await _authService.signOut();
    if (mounted) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final likesProvider = Provider.of<LikesProvider>(context, listen: false);
      eventProvider.clearEvent();
      likesProvider.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              eventProvider.hasJoinedEvent 
                  ? eventProvider.currentEvent!.name 
                  : 'FestiveLink'
            ),
            actions: [
              if (eventProvider.hasJoinedEvent)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => eventProvider.refreshEventUsers(),
                ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') _signOut();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: eventProvider.hasJoinedEvent
              ? _screens[_currentIndex]
              : _buildEventJoinPrompt(),
          bottomNavigationBar: eventProvider.hasJoinedEvent
              ? BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: const Color(0xFF1E1E1E),
                  selectedItemColor: Colors.pink,
                  unselectedItemColor: Colors.grey,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.explore),
                      label: 'Discover',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite),
                      label: 'Likes You',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.chat),
                      label: 'Matches',
                    ),
                  ],
                )
              : null,
          floatingActionButton: !eventProvider.hasJoinedEvent
              ? FloatingActionButton.extended(
                  onPressed: _openQRScanner,
                  backgroundColor: Colors.pink,
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: const Text(
                    'Scan QR Code',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildEventJoinPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 32),
            const Text(
              'Join an Event',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Scan an event QR code to start discovering people at your cultural festival',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _openQRScanner,
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text(
                  'Scan Event QR Code',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
