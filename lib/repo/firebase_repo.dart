import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import '../model/geo_manager.dart';

class FirebaseRepository {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  Future<void> saveUserLocation(String userId, Position position) async {
    try {
      await _databaseRef.child("users/$userId/location").set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Erreur lors de la sauvegarde de la localisation : $e");
      throw Exception("Failed to save location: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getNearbyUsers(
      Position userPosition, double radiusInKm) async {
    try {
      final snapshot = await _databaseRef.child("users").get();
      if (!snapshot.exists) {
        return [];
      }

      final usersData = snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> nearbyUsers = [];

      usersData.forEach((key, value) {
        if (value['location'] != null) {
          final location = value['location'];
          final double userLat = location['latitude'];
          final double userLon = location['longitude'];
          final distance = GeoManager.calculateDistance(
            userPosition.latitude,
            userPosition.longitude,
            userLat,
            userLon,
          );

          if (distance <= radiusInKm) {
            nearbyUsers.add({
              'id': key,
              'distance': distance,
              ...value,
            });
          }
        }
      });

      nearbyUsers.sort((a, b) => (a['distance'] as double)
          .compareTo(b['distance'] as double));

      return nearbyUsers;
    } catch (e) {
      print("Erreur lors de la récupération des utilisateurs proches : $e");
      throw Exception("Failed to fetch nearby users: $e");
    }
  }
}
