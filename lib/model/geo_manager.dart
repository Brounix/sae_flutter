import 'package:geolocator/geolocator.dart';
import 'dart:math';

class GeoManager {
  Future<Position?> getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Services de localisation désactivés. Veuillez les activer.");
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Permission de localisation refusée par l'utilisateur.");
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print(
            "Permission de localisation refusée de manière permanente. Veuillez modifier les paramètres de l'application.");
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print("Position obtenue : Latitude ${position.latitude}, Longitude ${position.longitude}");
      return position;
    } catch (e) {
      print("Erreur lors de l'obtention de la position : $e");
      return null;
    }
  }

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; //terre

    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
}

