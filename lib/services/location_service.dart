import 'package:geolocator/geolocator.dart';

class CalmingPlace {
  final String name;
  final double lat;
  final double lng;
  final String type;
  
  CalmingPlace({required this.name, required this.lat, required this.lng, required this.type});
}

class LocationService {
  static final LocationService instance = LocationService._init();
  LocationService._init();

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  List<CalmingPlace> getCalmingLocations() {
    return [
      CalmingPlace(name: 'City Park', lat: 28.6139, lng: 77.2090, type: 'Park'),
      CalmingPlace(name: 'Meditation Center', lat: 28.6129, lng: 77.2295, type: 'Meditation'),
      CalmingPlace(name: 'Community Hospital', lat: 28.6289, lng: 77.2065, type: 'Hospital'),
      CalmingPlace(name: 'Mental Health Clinic', lat: 28.6189, lng: 77.2195, type: 'Therapist'),
      CalmingPlace(name: 'Riverside Walk', lat: 28.6169, lng: 77.2150, type: 'Nature'),
      CalmingPlace(name: 'Temple', lat: 28.6239, lng: 77.2100, type: 'Spiritual'),
    ];
  }
}
