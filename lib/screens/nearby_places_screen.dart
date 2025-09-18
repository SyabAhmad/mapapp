import 'package:flutter/material.dart';
import '../widgets/place_card.dart';
import '../data/mock_places.dart';
import '../screens/home_screen.dart';

class NearbyPlacesScreen extends StatefulWidget {
  const NearbyPlacesScreen({super.key});

  @override
  State<NearbyPlacesScreen> createState() => _NearbyPlacesScreenState();
}

class _NearbyPlacesScreenState extends State<NearbyPlacesScreen> {
  List<MockPlace> displayedPlaces = MockPlacesData.places;
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Places'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions();
            },
          ),
        ],
      ),
      body: displayedPlaces.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.place, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No nearby places found'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: displayedPlaces.length,
              itemBuilder: (context, index) {
                final place = displayedPlaces[index];
                return PlaceCard(
                  place: {
                    'id': place.id,
                    'name': place.name,
                    'category': place.category,
                    'rating': place.rating,
                    'distance': '0.5 km', // This would be calculated in real app
                    'latitude': place.location.latitude,
                    'longitude': place.location.longitude,
                    'image': 'https://via.placeholder.com/80',
                  },
                  onTap: () {
                    // Show place details
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => PlaceDetailSheet(place: place),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FilterBottomSheet(
          onFilterApplied: (category) {
            setState(() {
              selectedCategory = category;
              if (category == 'All') {
                displayedPlaces = MockPlacesData.places;
              } else {
                displayedPlaces = MockPlacesData.places
                    .where((place) => place.category == category)
                    .toList();
              }
            });
            Navigator.pop(context);
          },
          selectedCategory: selectedCategory,
        );
      },
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final Function(String) onFilterApplied;
  final String selectedCategory;

  const FilterBottomSheet({
    super.key,
    required this.onFilterApplied,
    required this.selectedCategory,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String selectedCategory;
  final List<String> categories = [
    'All',
    'Cafe',
    'Fast Food',
    'Restaurant',
    'Sandwich',
  ];

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Category',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              return FilterChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    selectedCategory = selected ? category : 'All';
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onFilterApplied(selectedCategory);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}