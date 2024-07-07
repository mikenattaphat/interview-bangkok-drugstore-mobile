import 'package:bangkok_drugstore_mobile/models/custom_geometry.dart';
import 'package:bangkok_drugstore_mobile/models/site_navigator.dart';
import 'package:flutter/material.dart';

class SiteNavigatorState with ChangeNotifier {
  final SiteNavigator _siteNavigator = SiteNavigator();

  SiteNavigator get siteNavigator => _siteNavigator;

  void setMyLocation(String locationName, CustomLocation location) {
    _siteNavigator.myLocationName = locationName;
    _siteNavigator.myLocation = location;
    notifyListeners();
  }

  void setSite(String siteId,CustomLocation location,int distance) {
    _siteNavigator.siteId = siteId;
    _siteNavigator.siteLocation = location;
    _siteNavigator.distance = distance;
    notifyListeners();
  }
}
