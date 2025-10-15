import 'package:evelink/providers/all_events_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evelink/constants/design_constants.dart';
import 'package:evelink/widgets/widgets.dart';
import 'package:evelink/widgets/enhanced_event_card.dart';
import 'package:evelink/widgets/circular_category_filter.dart';
import 'event_detail_screen.dart';
import 'package:evelink/models/models.dart';

class AllEventsScreen extends StatefulWidget {
  const AllEventsScreen({super.key});

  @override
  State<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  // Icon mapping for categories
  final Map<String, IconData> _categoryIcons = {
    'All': Icons.all_inclusive,
    'Professional & Business': Icons.business_center,
    'Conference': Icons.people,
    'Seminar': Icons.school,
    'Workshop': Icons.build,
    'Panel Discussion': Icons.group_work,
    'Networking Event': Icons.connected_tv,
    'Product Launch': Icons.rocket_launch,
    'Startup Pitch': Icons.lightbulb,
    'Career Fair': Icons.work,
    'Business Meetup': Icons.handshake,
    'Team Building': Icons.diversity_3,
    'Technology': Icons.computer,
    'Leadership': Icons.leaderboard,
    'Entrepreneurship': Icons.business,
    'Innovation': Icons.auto_awesome,
    'Research & Development': Icons.science,
    'Skill Development': Icons.psychology,
    'Design Thinking': Icons.design_services,
    'Digital Transformation': Icons.transform,
    'Finance': Icons.attach_money,
    'Marketing': Icons.ads_click,
    'Healthcare': Icons.medical_services,
    'Real Estate': Icons.real_estate_agent,
    'Education': Icons.school,
    'Manufacturing': Icons.factory,
    'Energy': Icons.bolt,
    'Legal & Compliance': Icons.gavel,
    'Human Resources': Icons.people_alt,
    'AI & Data Science': Icons.smart_toy,
    'Keynote': Icons.mic,
    'Guest Lecture': Icons.record_voice_over,
    'Fireside Chat': Icons.chat_bubble,
    'Expert Talk': Icons.forum,
    'Panel Talk': Icons.groups,
    'Singles Mixer': Icons.favorite,
    'Speed Dating': Icons.schedule,
    'Matchmaking': Icons.connecting_airports,
    'Friendship': Icons.people_outline,
    'Hangout': Icons.coffee,
    'Meet & Greet': Icons.waving_hand,
    'Icebreaker': Icons.ac_unit,
    'Social Mixer': Icons.diversity_2,
    'Music Concert': Icons.music_note,
    'DJ Night': Icons.headphones,
    'Dance Party': Icons.celebration,
    'Movie Screening': Icons.movie,
    'Stand-up Comedy': Icons.theater_comedy,
    'Karaoke Night': Icons.mic_none,
    'Open Mic': Icons.mic_external_on,
    'Festival Celebration': Icons.festival,
    'Game Night': Icons.sports_esports,
    'Food Fest': Icons.fastfood,
    'Wine Tasting': Icons.wine_bar,
    'Cocktail Night': Icons.local_bar,
    'Coffee Meetup': Icons.coffee_maker,
    'Dinner Party': Icons.dinner_dining,
    'Brunch Event': Icons.brunch_dining,
    'Bar Crawl': Icons.local_drink,
    'BBQ Night': Icons.outdoor_grill,
    'Yoga Session': Icons.self_improvement,
    'Meditation Camp': Icons.psychology,
    'Fitness Meetup': Icons.fitness_center,
    'Nature Walk': Icons.nature,
    'Hiking Trip': Icons.terrain,
    'Beach Party': Icons.beach_access,
    'Camping Night': Icons.cabin,
    'Adventure Trip': Icons.sports,
    'Art Exhibition': Icons.palette,
    'Photography Meetup': Icons.camera_alt,
    'Cultural Night': Icons.theater_comedy_outlined,
    'Book Club': Icons.menu_book,
    'Poetry Slam': Icons.create,
    'Theatre Play': Icons.theaters,
    'Fashion Show': Icons.style_rounded,
    'Dance Performance': Icons.airline_seat_flat,
    'Volunteering': Icons.volunteer_activism,
    'Charity Event': Icons.heart_broken,
    'Pet Meetup': Icons.pets,
    'Hobby Club': Icons.toys,
    'Sports Meetup': Icons.sports_baseball,
    'Board Games': Icons.casino,
    'Travel Meetup': Icons.travel_explore,
    'Local Market': Icons.local_grocery_store,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AllEventsProvider>(context, listen: false);
      provider.listenToAllEvents();
      _searchController.addListener(() {
        provider.updateSearchQuery(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: DesignConstants.backgroundColor,
        body: Consumer<AllEventsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.allEvents.isEmpty) {
              return _buildLoadingState();
            }

            if (provider.error != null) {
              return _buildErrorState(provider.error!);
            }

            // Mega Events: always unfiltered
            final megaEvents = provider.allEvents.where((e) => e.isMegaEvent).toList();

            // Other Events: filtered by search and category/tag
            final filteredEvents = provider.filteredEvents.where((e) => !e.isMegaEvent).toList();

            return RefreshIndicator(
              onRefresh: () async => provider.listenToAllEvents(),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: DesignConstants.backgroundColor,
                    elevation: 0,
                    pinned: true,
                    title: const Text(
                      'EVELINK',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: DesignConstants.primaryColor,
                      ),
                    ),
                    centerTitle: false,
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignConstants.screenPadding,
                        vertical: 8,
                      ),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: DesignConstants.cardColor,
                          borderRadius: BorderRadius.circular(DesignConstants.buttonBorderRadius),
                          boxShadow: [DesignConstants.cardShadow],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: DesignConstants.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Search events, venues, or tags...',
                            hintStyle: TextStyle(color: DesignConstants.textLight),
                            prefixIcon: Icon(Icons.search, color: DesignConstants.primaryColor),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: DesignConstants.sectionSpacing)),

                  // Mega Events Section: always unfiltered
                  if (megaEvents.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _buildSectionHeader('🔥 Mega Events', 'Most popular events'),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 280,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: DesignConstants.screenPadding),
                          itemCount: megaEvents.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final event = megaEvents[index];
                            return SizedBox(
                              width: 280,
                              child: EnhancedEventCard(
                                event: event,
                                isLarge: true,
                                onTap: () => _navigateToEventDetail(event),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: DesignConstants.sectionSpacing)),
                  ],

                  // Categories Section (filter only applies to "All Events"/grid below)
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('🎯 Categories', 'Browse by interest'),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: DesignConstants.sectionSpacing)),
                  SliverToBoxAdapter(
                    child: _buildCategoryFilters(provider),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: DesignConstants.sectionSpacing)),

                  // All Events Section
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('📅 All Events', 'Discover something new'),
                  ),

                  // Grid of filtered events (excluding mega events), with responsive layout and overflow fixes
                  if (filteredEvents.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: DesignConstants.screenPadding),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final event = filteredEvents[index];
                            return EnhancedEventCard(
                              event: event,
                              isLarge: false,
                              onTap: () => _navigateToEventDetail(event),
                            );
                          },
                          childCount: filteredEvents.length,
                        ),
                      ),
                    )
                  else if (provider.allEvents.where((e) => !e.isMegaEvent).isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildEmptyState(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(DesignConstants.primaryColor),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: DesignConstants.textLight),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              color: DesignConstants.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: DesignConstants.textLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<AllEventsProvider>(context, listen: false);
              provider.listenToAllEvents();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignConstants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignConstants.buttonBorderRadius),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 64, color: DesignConstants.textLight),
          SizedBox(height: 16),
          Text(
            'No events found',
            style: TextStyle(
              fontSize: 18,
              color: DesignConstants.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter to find more events',
            style: TextStyle(color: DesignConstants.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(AllEventsProvider provider) {
    // All unique tags from all events
    final eventTags = provider.uniqueTags.map((e) => e.trim()).toSet();

    // Keep only category icons that appear in events (plus 'All')
    final filteredIcons = Map.fromEntries(
      _categoryIcons.entries.where((entry) =>
      entry.key == 'All' || eventTags.contains(entry.key)),
    );

    // Build the list of category titles (use filteredIcons keys)
    final categories = filteredIcons.keys.take(10).toList();

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: DesignConstants.screenPadding),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == 'All'
              ? provider.selectedTag == null
              : provider.selectedTag == category;

          return CircularCategoryFilter(
            title: category.length > 12 ? '${category.substring(0, 12)}...' : category,
            icon: filteredIcons[category] ?? Icons.event,
            isSelected: isSelected,
            onTap: () {
              provider.selectTag(category == 'All' ? null : category);
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignConstants.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DesignConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: DesignConstants.textLight),
          ),
        ],
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
