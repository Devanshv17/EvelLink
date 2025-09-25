import 'package:evelink/models/event_model.dart';
import 'package:evelink/providers/all_events_provider.dart';
import 'package:evelink/screens/events/event_detail_screen.dart';
import 'package:evelink/utils/app_constants.dart';
import 'package:evelink/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllEventsScreen extends StatefulWidget {
  const AllEventsScreen({super.key});

  @override
  State<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch events when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AllEventsProvider>(context, listen: false).fetchAllEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using a CustomScrollView to easily combine different scrolling elements
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    const Text('Mega Events', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            // The large carousel for mega events
            SliverToBoxAdapter(
              child: _buildMegaEventsCarousel(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Explore Events', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildFilterChips(),
                  ],
                ),
              ),
            ),
            // The horizontal list for other events
            _buildHorizontalEventList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for events...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor == Colors.white ? Colors.grey[200] : Colors.grey[800],
      ),
    );
  }

  Widget _buildMegaEventsCarousel() {
    return Consumer<AllEventsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.allEvents.isEmpty) {
          // Show a loading shimmer or placeholder for the carousel
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }
        // Using first 3 events as "mega" events. You can change this logic.
        final megaEvents = provider.allEvents.take(3).toList();
        if (megaEvents.isEmpty) {
          return const SizedBox.shrink(); // Don't show if there are no mega events
        }
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: PageView.builder(
            itemCount: megaEvents.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: EventCard(
                  event: megaEvents[index],
                  isLarge: true,
                  onTap: () => _navigateToEventDetail(megaEvents[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    // These are static for now, but could be dynamic later
    final filters = ['Music', 'Art', 'Tech', 'Food', 'Sports', 'Conference'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return Chip(
            label: Text(filters[index]),
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey[300]!),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
      ),
    );
  }

  Widget _buildHorizontalEventList() {
    return SliverToBoxAdapter(
      child: Consumer<AllEventsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.allEvents.isEmpty) {
            return const SizedBox.shrink(); // Don't show this section while initially loading
          }
          // The rest of the events after the "mega" ones
          final otherEvents = provider.allEvents.skip(3).toList();
          if (otherEvents.isEmpty) {
            return const SizedBox.shrink();
          }
          return SizedBox(
            height: 220, // Height for the smaller event cards
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: otherEvents.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 160, // Width for the smaller event cards
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: EventCard(
                      event: otherEvents[index],
                      onTap: () => _navigateToEventDetail(otherEvents[index]),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToEventDetail(EventModel event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(event: event),
      ),
    );
  }
}

