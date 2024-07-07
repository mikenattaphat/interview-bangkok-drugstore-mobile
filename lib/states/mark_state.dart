import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkState with ChangeNotifier {
  final Set<Marker> _markers = {};

  Set<Marker> get markers => _markers;

  void addMarker(Marker marker) {
    _markers.add(marker);
    notifyListeners();
  }

  void clearMarker() {
    _markers.clear();
    notifyListeners();
  }

  void clearMarkerFinal() {
    if (_markers.length > 1) {
      _markers.remove(_markers.last);
      notifyListeners();
    }
  }
}
