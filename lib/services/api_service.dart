import 'dart:convert';
import 'package:bangkok_drugstore_mobile/models/custom_geometry.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ApiService {
  static final String _baseUrl = dotenv.env['BASE_URL']!;


  void deepLinkGoogleMap(double originLat, double originLng, double destLat,double destLng) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLng&destination=$destLat,$destLng');
    await launchUrl(url);
  }

    Future<String> getPlaceIdFromCoordinates(LatLng location) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=AIzaSyDJ4bVRn11unNIbAG1jsQJ8QvJxycyCZCQ';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['place_id'];
      }
    }
    return '';
  }

    Future<CustomPlaceDetails> getDetailsByPlaceId(
      String placeId, String apiKey) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return CustomPlaceDetails.fromJson(json.decode(response.body)['result']);
    } else {
      throw Exception('Failed to load place details');
    }
  }

  Future<dynamic> getRequest(String endpoint) async {
    final response = await http.get(Uri.parse(_baseUrl + endpoint));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> postRequest(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(_baseUrl + endpoint),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
