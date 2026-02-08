import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

/// Service for handling location permissions and getting user location
@injectable
class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current position if permission is granted
  /// Returns null if permission is denied or location service is disabled
  Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('📍 Location service is disabled');
        return null;
      }

      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          print('📍 Permission denied after request');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('📍 Permission denied forever');
        return null;
      }

      print('📍 Getting current position...');

      // Use lower accuracy and longer timeout for better Android compatibility
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium, // Changed from high to medium
          timeLimit: Duration(seconds: 30), // Increased from 15 to 30
        ),
      );

      print(
          '📍 Position retrieved: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('📍 Error getting position: $e');
      return null;
    }
  }

  /// Check if we have permission (either whileInUse or always)
  Future<bool> hasPermission() async {
    final permission = await checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Open app settings for the user to grant permission
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
