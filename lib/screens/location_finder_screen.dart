import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';

class LocationFinderScreen extends StatefulWidget {
  const LocationFinderScreen({super.key});

  @override
  State<LocationFinderScreen> createState() => _LocationFinderScreenState();
}

class _LocationFinderScreenState extends State<LocationFinderScreen> {
  Position? _currentPosition;
  List<CalmingPlace> _places = [];
  bool _loading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    final position = await LocationService.instance.getCurrentLocation();
    final places = LocationService.instance.getCalmingLocations();
    
    setState(() {
      _currentPosition = position;
      _places = places;
      _loading = false;
      _permissionDenied = position == null;
    });
  }

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }

  void _showPlaceDetails(CalmingPlace place) {
    final distance = _currentPosition != null
        ? LocationService.instance.calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            place.lat,
            place.lng,
          )
        : null;

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(place.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Type: ${place.type}'),
            if (distance != null) Text('Distance: ${distance.toStringAsFixed(2)} km'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _openInGoogleMaps(place.lat, place.lng),
              icon: const Icon(Icons.directions),
              label: const Text('Open in Google Maps'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Calm Places')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _permissionDenied
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Location permission denied',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You can still browse the map, but your current location won\'t be shown',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => setState(() {
                            _loading = true;
                            _initializeMap();
                          }),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                        : LatLng(28.6139, 77.2090),
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.mental_wellness',
                    ),
                    MarkerLayer(
                      markers: [
                        if (_currentPosition != null)
                          Marker(
                            point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.my_location, color: Colors.blue, size: 40),
                          ),
                        ..._places.map((place) => Marker(
                              point: LatLng(place.lat, place.lng),
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () => _showPlaceDetails(place),
                                child: Icon(
                                  _getIconForType(place.type),
                                  color: _getColorForType(place.type),
                                  size: 40,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Park':
        return Icons.park;
      case 'Meditation':
        return Icons.self_improvement;
      case 'Hospital':
        return Icons.local_hospital;
      case 'Therapist':
        return Icons.psychology;
      case 'Nature':
        return Icons.nature;
      case 'Spiritual':
        return Icons.temple_hindu;
      default:
        return Icons.place;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Park':
        return Colors.green;
      case 'Meditation':
        return Colors.purple;
      case 'Hospital':
        return Colors.red;
      case 'Therapist':
        return Colors.orange;
      case 'Nature':
        return Colors.teal;
      case 'Spiritual':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
