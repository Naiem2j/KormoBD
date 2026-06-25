/* Location Service
  Future version: GPS / Google Maps API
  Current version: Demo (Bangladesh based) */

class LocationService {
  /// Get current location (dummy)
  Future<String> getCurrentLocation() async {
    await Future.delayed(const Duration(seconds: 1));
    return "Dhaka, Bangladesh";
  }

  /// Get nearby jobs (logic placeholder)
  bool isNearby(String jobLocation, String userLocation) {
    return jobLocation == userLocation;
  }
}
