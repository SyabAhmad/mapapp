import 'dart:math' show cos, sqrt, asin;
import 'package:latlong2/latlong.dart';

class MockPlace {
  final String id;
  final String name;
  final String category;
  final double rating;
  final LatLng location;
  final String address;
  final String description;

  MockPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.location,
    required this.address,
    required this.description,
  });
}

class MockPlacesData {
  static final List<MockPlace> places = [
    MockPlace(
      id: '1',
      name: 'Starbucks Downtown',
      category: 'Cafe',
      rating: 4.5,
      location: LatLng(37.7749, -122.4194),
      address: '123 Main St, San Francisco, CA',
      description: 'Premium coffee and snacks',
    ),
    MockPlace(
      id: '2',
      name: 'McDonald\'s Union Square',
      category: 'Fast Food',
      rating: 4.0,
      location: LatLng(37.7750, -122.4195),
      address: '456 Market St, San Francisco, CA',
      description: 'Fast food restaurant',
    ),
    MockPlace(
      id: '3',
      name: 'Pizza Hut Central',
      category: 'Restaurant',
      rating: 4.2,
      location: LatLng(37.7751, -122.4196),
      address: '789 Broadway, San Francisco, CA',
      description: 'Family pizza restaurant',
    ),
    MockPlace(
      id: '4',
      name: 'Burger King Financial District',
      category: 'Fast Food',
      rating: 4.1,
      location: LatLng(37.7752, -122.4197),
      address: '101 California St, San Francisco, CA',
      description: 'Flame-grilled burgers',
    ),
    MockPlace(
      id: '5',
      name: 'Subway Mission',
      category: 'Sandwich',
      rating: 4.3,
      location: LatLng(37.7753, -122.4198),
      address: '202 Valencia St, San Francisco, CA',
      description: 'Fresh sandwiches made to order',
    ),
    MockPlace(
      id: '6',
      name: 'KFC Castro',
      category: 'Fast Food',
      rating: 3.9,
      location: LatLng(37.7754, -122.4199),
      address: '303 Castro St, San Francisco, CA',
      description: 'Fried chicken restaurant',
    ),
    MockPlace(
      id: '7',
      name: 'Dunkin\' Donuts SoMa',
      category: 'Cafe',
      rating: 4.4,
      location: LatLng(37.7755, -122.4200),
      address: '404 Folsom St, San Francisco, CA',
      description: 'Coffee and donuts',
    ),
    MockPlace(
      id: '8',
      name: 'Taco Bell Marina',
      category: 'Fast Food',
      rating: 3.8,
      location: LatLng(37.7756, -122.4201),
      address: '505 Marina Blvd, San Francisco, CA',
      description: 'Mexican-inspired fast food',
    ),
    MockPlace(
      id: '9',
      name: 'Blue Bottle Coffee',
      category: 'Cafe',
      rating: 4.7,
      location: LatLng(37.7757, -122.4202),
      address: '606 Hayes St, San Francisco, CA',
      description: 'Artisanal coffee roasters',
    ),
    MockPlace(
      id: '10',
      name: 'In-N-Out Burger',
      category: 'Fast Food',
      rating: 4.6,
      location: LatLng(37.7758, -122.4203),
      address: '707 Van Ness Ave, San Francisco, CA',
      description: 'California burger chain',
    ),
  ];

  // Search places by name or category
  static List<MockPlace> searchPlaces(String query) {
    if (query.isEmpty) return places;
    
    return places.where((place) {
      final searchQuery = query.toLowerCase();
      return place.name.toLowerCase().contains(searchQuery) ||
             place.category.toLowerCase().contains(searchQuery) ||
             place.description.toLowerCase().contains(searchQuery);
    }).toList();
  }

  // Find place by ID
  static MockPlace? findById(String id) {
    try {
      return places.firstWhere((place) => place.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get places near a location (within 2km for demo)
  static List<MockPlace> getNearbyPlaces(LatLng currentLocation) {
    return places.where((place) {
      final distance = calculateDistance(currentLocation, place.location);
      return distance <= 2.0; // 2km radius
    }).toList();
  }

  // Simple distance calculation (in km)
  static double calculateDistance(LatLng from, LatLng to) {
    final lat1 = from.latitude;
    final lon1 = from.longitude;
    final lat2 = to.latitude;
    final lon2 = to.longitude;
    
    final p = 0.017453292519943295;
    final c = cos;
    final a = 0.5 - c((lat2 - lat1) * p) / 2 + 
              c(lat1 * p) * c(lat2 * p) * 
              (1 - c((lon2 - lon1) * p)) / 2;
    
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}