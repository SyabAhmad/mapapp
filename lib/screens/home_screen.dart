import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../data/mock_places.dart';

class HomeScreen extends StatefulWidget {
  final MockPlace? initialPlace;

  const HomeScreen({super.key, this.initialPlace});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MapController mapController;
  LatLng? currentPosition;
  bool isLoading = true;
  List<Marker> placeMarkers = [];
  Marker? selectedMarker;
  double _zoom = 14;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _getCurrentLocation();

    if (widget.initialPlace != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleExternalPlace(widget.initialPlace!);
      });
    }
  }

  Future<void> _handleExternalPlace(MockPlace place) async {
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      selectedMarker = Marker(
        point: place.location,
        width: 50,
        height: 50,
        child: const Icon(
          Icons.location_pin,
          color: Colors.blue,
          size: 48,
        ),
      );
    });

    try {
      mapController.move(place.location, 16);
    } catch (_) {}

    if (mounted) {
      showModalBottomSheet(
        context: context,
        builder: (context) => PlaceDetailSheet(place: place),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')),
          );
        }
        setState(() => isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied.')),
            );
          }
          setState(() => isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission permanently denied.')),
          );
        }
        setState(() => isLoading = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      currentPosition = LatLng(pos.latitude, pos.longitude);
      _loadNearbyPlaces();
      setState(() {
        isLoading = false;
      });

      // move map to current location when first obtained
      try {
        mapController.move(currentPosition!, _zoom);
      } catch (_) {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
        setState(() => isLoading = false);
      }
    }
  }

  void _loadNearbyPlaces() {
    if (currentPosition == null) return;
    final nearby = MockPlacesData.getNearbyPlaces(currentPosition!);
    setState(() {
      placeMarkers = nearby.map((place) {
        return Marker(
          width: 50,
          height: 50,
          point: place.location,
          child: GestureDetector(
            onTap: () => _onPlaceMarkerTapped(place),
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 36,
            ),
          ),
        );
      }).toList();
    });
  }

  void _onPlaceMarkerTapped(MockPlace place) {
    setState(() {
      selectedMarker = Marker(
        point: place.location,
        width: 50,
        height: 50,
        child: const Icon(
          Icons.location_pin,
          color: Colors.blue,
          size: 48,
        ),
      );
    });

    try {
      mapController.move(place.location, 16);
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      builder: (context) => PlaceDetailSheet(place: place),
    );
  }

  void _handleSearchResult(MockPlace place) {
    setState(() {
      selectedMarker = Marker(
        point: place.location,
        width: 50,
        height: 50,
        child: const Icon(
          Icons.location_pin,
          color: Colors.blue,
          size: 48,
        ),
      );
    });

    try {
      mapController.move(place.location, 16);
    } catch (_) {}

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
            onPressed: () async {
              final delegate = PlaceSearchDelegate(onPlaceSelected: (place) {
                _handleSearchResult(place);
              });
              await showSearch<MockPlace?>(
                context: context,
                delegate: delegate,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentPosition == null
              ? const Center(child: Text('Unable to determine current location'))
              : FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: currentPosition,
                    zoom: _zoom,
                    maxZoom: 18,
                    onPositionChanged: (pos, _) {
                      _zoom = pos.zoom ?? _zoom;
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.mapapp',
                      // network tile provider is default; network errors will appear in logs.
                      // If you frequently run offline, consider an offline tile solution.
                    ),
                    MarkerLayer(
                      markers: [
                        // current location marker
                        if (currentPosition != null)
                          Marker(
                            width: 40,
                            height: 40,
                            point: currentPosition!,
                            child: const Icon(Icons.my_location, color: Colors.blue),
                          ),
                        ...placeMarkers,
                        if (selectedMarker != null) selectedMarker!,
                      ],
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (currentPosition != null) {
            try {
              mapController.move(currentPosition!, 16);
            } catch (_) {}
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Current location not available')),
            );
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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, size: 48, color: Colors.white70),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${place.category} • ${place.rating} ★'),
                    const SizedBox(height: 4),
                    Text(place.address, style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(place.description, style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// Search delegate
class PlaceSearchDelegate extends SearchDelegate<MockPlace?> {
  final Function(MockPlace) onPlaceSelected;

  PlaceSearchDelegate({required this.onPlaceSelected});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = MockPlacesData.searchPlaces(query);
    if (results.isEmpty) {
      return const Center(child: Text('No results'));
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final p = results[index];
        return ListTile(
          title: Text(p.name),
          subtitle: Text('${p.category} • ${p.rating} ★'),
          onTap: () {
            onPlaceSelected(p);
            close(context, p);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty ? MockPlacesData.places : MockPlacesData.searchPlaces(query);
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final p = suggestions[index];
        return ListTile(
          title: Text(p.name),
          subtitle: Text(p.category),
          onTap: () {
            query = p.name;
            showResults(context);
          },
        );
      },
    );
  }
}