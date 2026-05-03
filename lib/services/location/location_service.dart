import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CalmingPlace {
  final String name;
  final double lat;
  final double lng;
  final String type;
  const CalmingPlace({required this.name, required this.lat, required this.lng, required this.type});
}

/// Fetches nearby calming locations via the Overpass API (OpenStreetMap),
/// with a local fallback when the network is unavailable.
class LocationService {
  static final LocationService instance = LocationService._init();
  LocationService._init();

  Future<Position?> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return null;
    }
    if (perm == LocationPermission.deniedForever) return null;
    return Geolocator.getCurrentPosition();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) =>
      Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;

  Future<List<CalmingPlace>> getCalmingLocations(Position? pos) async {
    if (pos == null) return [];
    final lat = pos.latitude, lng = pos.longitude;

    try {
      final query = '''
[out:json][timeout:25];
(
  node["amenity"="hospital"](around:5000,$lat,$lng);
  node["amenity"="clinic"](around:5000,$lat,$lng);
  node["healthcare"="psychotherapist"](around:5000,$lat,$lng);
  node["leisure"="park"](around:5000,$lat,$lng);
  node["leisure"="garden"](around:5000,$lat,$lng);
  node["amenity"="meditation_centre"](around:5000,$lat,$lng);
  node["amenity"="place_of_worship"](around:5000,$lat,$lng);
  node["natural"="water"](around:5000,$lat,$lng);
);
out body;
''';
      final resp = await http
          .post(Uri.parse('https://overpass-api.de/api/interpreter'), body: query)
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final elements = (json.decode(resp.body)['elements'] as List);
        final places = <CalmingPlace>[];
        for (final el in elements) {
          final tags = el['tags'] as Map<String, dynamic>?;
          if (tags == null) continue;
          places.add(CalmingPlace(
            name: tags['name'] ?? _defaultName(tags),
            lat: el['lat'] as double,
            lng: el['lon'] as double,
            type: _categorize(tags),
          ));
          if (places.length >= 20) break;
        }
        return places;
      }
    } catch (_) {}

    // Fallback
    return [
      CalmingPlace(name: 'City Park',           lat: lat + 0.010, lng: lng + 0.010, type: 'Park'),
      CalmingPlace(name: 'Meditation Center',   lat: lat - 0.015, lng: lng + 0.020, type: 'Meditation'),
      CalmingPlace(name: 'Community Hospital',  lat: lat + 0.020, lng: lng - 0.010, type: 'Hospital'),
      CalmingPlace(name: 'Mental Health Clinic',lat: lat - 0.010, lng: lng - 0.015, type: 'Therapist'),
      CalmingPlace(name: 'Riverside Walk',      lat: lat + 0.005, lng: lng + 0.015, type: 'Nature'),
      CalmingPlace(name: 'Wellness Temple',     lat: lat + 0.018, lng: lng - 0.005, type: 'Spiritual'),
    ];
  }

  String _defaultName(Map<String, dynamic> tags) {
    if (tags['amenity'] != null) {
      return tags['amenity'].toString().replaceAll('_', ' ').split(' ')
          .map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
    }
    if (tags['leisure'] != null) return 'Park';
    if (tags['natural'] != null) return 'Natural Area';
    return 'Place';
  }

  String _categorize(Map<String, dynamic> tags) {
    if (tags['amenity'] == 'hospital' || tags['amenity'] == 'clinic') return 'Hospital';
    if (tags['healthcare'] == 'psychotherapist') return 'Therapist';
    if (tags['leisure'] == 'park' || tags['leisure'] == 'garden') return 'Park';
    if (tags['amenity'] == 'meditation_centre') return 'Meditation';
    if (tags['amenity'] == 'place_of_worship') return 'Spiritual';
    if (tags['natural'] == 'water') return 'Nature';
    return 'Park';
  }
}
