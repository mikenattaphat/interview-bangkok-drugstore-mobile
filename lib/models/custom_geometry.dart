
class CustomPlaceDetails {
  final CustomGeometry geometry;
  final String formattedAddress;

  CustomPlaceDetails({required this.geometry, required this.formattedAddress});

  factory CustomPlaceDetails.fromJson(Map<String, dynamic> json) {
    return CustomPlaceDetails(
      geometry: CustomGeometry.fromJson(json['geometry']),
      formattedAddress: json['formatted_address'] ?? '',
    );
  }
}

class CustomGeometry {
  final CustomLocation location;

  CustomGeometry({required this.location});

  factory CustomGeometry.fromJson(Map<String, dynamic> json) {
    return CustomGeometry(
      location: CustomLocation.fromJson(json['location']),
    );
  }
}

class CustomLocation {
  final double lat;
  final double lng;

  CustomLocation({required this.lat, required this.lng});

  factory CustomLocation.fromJson(Map<String, dynamic> json) {
    return CustomLocation(
      lat: json['lat'] != null ? json['lat'].toDouble() : 0.0,
      lng: json['lng'] != null ? json['lng'].toDouble() : 0.0,
    );
  }
}