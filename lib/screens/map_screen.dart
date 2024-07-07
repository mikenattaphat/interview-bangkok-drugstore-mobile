import 'package:bangkok_drugstore_mobile/models/custom_geometry.dart';
import 'package:bangkok_drugstore_mobile/services/api_service.dart';
import 'package:bangkok_drugstore_mobile/states/mark_state.dart';
import 'package:bangkok_drugstore_mobile/states/site_navigator_state.dart';
import 'package:bangkok_drugstore_mobile/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final String _googleMapKey = dotenv.env['GOOGLE_API_KEY']!;
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  CustomPlaceDetails? _selectedPlaceDetails;
  bool _isLocationMarked = false;
  final LatLng _center = const LatLng(13.714791, 100.594908);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    if (_searchController.text.isEmpty) {
      _clearSearchResults();
    }
  }

  void _clearSearchResults() {
    setState(() {
      _selectedPlaceDetails = null;
      context.read<MarkState>().clearMarker();
      _isLocationMarked = false;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    _onMapTapped(currentLatLng);
  }

  void _onMapTapped(LatLng location) async {
    String placeId = await ApiService().getPlaceIdFromCoordinates(location);
    if (placeId.isNotEmpty) {
      final details =
          await ApiService().getDetailsByPlaceId(placeId, _googleMapKey);

      _mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(location.latitude, location.longitude),
        ),
      );
      setState(() {
        _selectedPlaceDetails = details;
        _searchController.text = details.formattedAddress;
        context.read<MarkState>().clearMarker();
        context.read<SiteNavigatorState>().setMyLocation(
            details.formattedAddress,
            CustomLocation(
                lat: details.geometry.location.lat,
                lng: details.geometry.location.lng));
        context.read<MarkState>().addMarker(
              Marker(
                markerId: MarkerId(placeId),
                position: LatLng(details.geometry.location.lat,
                    details.geometry.location.lng),
              ),
            );
        _isLocationMarked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Center(
          child: Text(
            'เลือกที่อยู่จัดส่งด่วน',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        icon: const IconThemeData(color: Colors.blue),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: context.watch<MarkState>().markers,
            onTap: _onMapTapped,
          ),
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: _buildSearchBox(),
          ),
          if (_isLocationMarked)
            Positioned(
              bottom: 0,
              left: -10,
              right: -10,
              child: _buildConfirmButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/search.svg',
            width: 24.0,
            height: 24.0,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GooglePlaceAutoCompleteTextField(
              boxDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              textEditingController: _searchController,
              googleAPIKey: _googleMapKey,
              inputDecoration: const InputDecoration(
                  hintText: 'ค้นหาที่อยู่จัดส่งสินค้า',
                  border: InputBorder.none,
                  hintStyle:
                      TextStyle(color: Color(0xFFABABAB), fontSize: 16.0)),
              debounceTime: 400,
              countries: ["th"],
              isLatLngRequired: true,
              itemClick: (item) async {},
              getPlaceDetailWithLatLng: (prediction) async {
                final placeId = prediction.placeId;
                if (placeId != null && placeId.isNotEmpty) {
                  final details = await ApiService()
                      .getDetailsByPlaceId(placeId, _googleMapKey);

                  final location = details.geometry.location;
                  _mapController.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(location.lat, location.lng),
                    ),
                  );
                  setState(() {
                    _selectedPlaceDetails = details;
                    _searchController.text = details.formattedAddress;
                    context.read<MarkState>().clearMarker();
                    context.read<SiteNavigatorState>().setMyLocation(
                        details.formattedAddress,
                        CustomLocation(lat: location.lat, lng: location.lng));
                    context.read<MarkState>().addMarker(
                          Marker(
                            markerId: MarkerId(placeId),
                            position: LatLng(location.lat, location.lng),
                          ),
                        );
                    _isLocationMarked = true;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'ที่อยู่* (ตำบล, อำเภอ, จังหวัด, รหัสไปรษณีย์)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_selectedPlaceDetails != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color.fromRGBO(231, 231, 231, 1))),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/mark.svg',
                            width: 24.0,
                            height: 24.0,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedPlaceDetails!.formattedAddress,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/icons/location_rounded.svg',
                            width: 24.0,
                            height: 24.0,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/site-list',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 179, 240, 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('ยืนยันตำแหน่ง',
                    style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            )
          ],
        ));
  }
}
