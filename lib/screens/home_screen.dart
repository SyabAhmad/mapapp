import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../data/mock_places.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late MapController mapController;
  LatLng? currentPosition;
  bool isLoading = true;
  List<Marker> placeMarkers = [];
  Marker? selectedMarker;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled')),
          );
        }
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permissions permanently denied'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () {
                  Geolocator.openAppSettings();
                },
              ),
            ),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          currentPosition = LatLng(position.latitude, position.longitude);
          isLoading = false;
          _loadNearbyPlaces();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _loadNearbyPlaces() {
    if (currentPosition != null) {
      final nearbyPlaces = MockPlacesData.getNearbyPlaces(currentPosition!);
      
      setState(() {
        placeMarkers = nearbyPlaces.map((place) {
          return Marker(
            point: place.location,
            child: GestureDetector(
              onTap: () => _onPlaceMarkerTapped(place),
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            ),
          );
        }).toList();
      });
    }
  }

  void _onPlaceMarkerTapped(MockPlace place) {
    setState(() {
      selectedMarker = Marker(
        point: place.location,
        child: Icon(
          Icons.location_pin,
          color: Colors.blue,
          size: 50,
        ),
      );
    });
    
    mapController.move(place.location, 16);
    
    // Show bottom sheet with place details
    showModalBottomSheet(
      context: context,
      builder: (context) => PlaceDetailSheet(place: place),
    );
  }

  void _handleSearchResult(MockPlace place) {
    setState(() {
      selectedMarker = Marker(
        point: place.location,
        child: Icon(
          Icons.location_pin,
          color: Colors.blue,
          size: 50,
        ),
      );
    });
    
    mapController.move(place.location, 16);
    
    // Show bottom sheet with place details
    showModalBottomSheet(
      context: context,
      builder: (context) => PlaceDetailSheet(place: place),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Places'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PlaceSearchDelegate(
                  onPlaceSelected: _handleSearchResult,
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentPosition == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Unable to get location'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          _getCurrentLocation();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: currentPosition!,
                    initialZoom: 15,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.mapapp',
                    ),
                    MarkerLayer(
                      markers: [
                        // Current location marker
                        Marker(
                          point: currentPosition!,
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                        // Place markers
                        ...placeMarkers,
                        // Selected marker (if any)
                        if (selectedMarker != null) selectedMarker!,
                      ],
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (currentPosition != null) {
            mapController.move(currentPosition!, 15);
            setState(() {
              selectedMarker = null;
            });
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

// Place Detail Bottom Sheet
class PlaceDetailSheet extends StatelessWidget {
  final MockPlace place;

  const PlaceDetailSheet({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${place.category} • ${place.rating} ★',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${place.rating}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            place.address,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            place.description,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Getting directions to ${place.name}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.directions),
              label: const Text('Get Directions'),
            ),
          ),
        ],
      ),
    );
  }
}

// Updated search delegate with proper mock data
class PlaceSearchDelegate extends SearchDelegate<MockPlace> {
  final Function(MockPlace) onPlaceSelected;
  
  PlaceSearchDelegate({required this.onPlaceSelected});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, MockPlace(
          id: '',
          name: '',
          category: '',
          rating: 0,
          location: LatLng(0, 0),
          address: '',
          description: '',
        ));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final results = MockPlacesData.searchPlaces(query);

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final place = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: const Icon(Icons.place, color: Colors.blue),
          ),
          title: Text(place.name),
          subtitle: Text('${place.category} • ${place.rating} ★'),
          onTap: () {
            onPlaceSelected(place);
            close(context, place);
          },
        );
      },
    );
  }
}