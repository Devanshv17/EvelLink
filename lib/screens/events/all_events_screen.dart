import 'package:evelink/providers/all_events_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import 'event_detail_screen.dart';
import '../../models/models.dart';

class AllEventsScreen extends StatefulWidget {
  const AllEventsScreen({super.key});

  @override
  State<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AllEventsProvider>(context, listen: false);
      // Use the new stream-based method
      provider.listenToAllEvents();
      // Add listener to update provider on search query change
      _searchController.addListener(() {
        provider.updateSearchQuery(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // The provider's dispose method is called automatically.
    // The incorrect call to stopListening() has been removed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Events'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: AppConstants.textPrimary,
      ),
      body: Consumer<AllEventsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.allEvents.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('An error occurred: ${provider.error}'));
          }

          final filteredEvents = provider.filteredEvents;
          final megaEvents = filteredEvents.where((e) => e.isMegaEvent).toList();
          final otherEvents = filteredEvents.where((e) => !e.isMegaEvent).toList();

          return RefreshIndicator(
            onRefresh: () async => provider.listenToAllEvents(),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or tag...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Mega Events Carousel
                if (megaEvents.isNotEmpty) ...[
                  _buildSectionHeader('Mega Events'),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.85),
                      itemCount: megaEvents.length,
                      itemBuilder: (context, index) {
                        final event = megaEvents[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: EventCard(
                            event: event,
                            isLarge: true,
                            onTap: () => _navigateToEventDetail(event),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Filter Chips
                _buildSectionHeader('Explore'),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      _buildFilterChip(context, 'All', provider.selectedTag == null),
                      ...provider.uniqueTags.map((tag) => _buildFilterChip(context, tag, provider.selectedTag == tag)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Other Events List
                if (otherEvents.isNotEmpty) ...[
                  _buildSectionHeader('Explore Events'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: otherEvents.map((event) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SizedBox(
                          height: 120, // Reduced height
                          child: EventCard(
                              event: event,
                              isLarge: false,
                              onTap: () => _navigateToEventDetail(event)
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ],

                if (filteredEvents.isEmpty && provider.allEvents.isNotEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text("No events match your search or filter."),
                    ),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    final provider = Provider.of<AllEventsProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          provider.selectTag(label == 'All' ? null : label);
        },
        selectedColor: AppConstants.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppConstants.textPrimary,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppConstants.primaryColor : Colors.grey.shade300),
        ),
      ),
    );
  }

  Padding _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _navigateToEventDetail(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(event: event),
      ),
    );
  }
}