import 'package:bangkok_drugstore_mobile/models/site_model.dart';
import 'package:bangkok_drugstore_mobile/services/api_service.dart';
import 'package:bangkok_drugstore_mobile/states/mark_state.dart';
import 'package:bangkok_drugstore_mobile/states/site_navigator_state.dart';
import 'package:bangkok_drugstore_mobile/widgets/custom_app_bar.dart';
import 'package:bangkok_drugstore_mobile/widgets/location_card.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapNavigateScreen extends StatefulWidget {
  const MapNavigateScreen({super.key});

  @override
  _MapNavigateScreenState createState() => _MapNavigateScreenState();
}

class _MapNavigateScreenState extends State<MapNavigateScreen> {
  SiteModel? siteModel;
  late GoogleMapController mapController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (siteModel == null) {
      fetchApiFindBySiteId();
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> fetchApiFindBySiteId() async {
    setState(() {
      isLoading = true;
    });

    try {
      String id = context.read<SiteNavigatorState>().siteNavigator.siteId!;
      final data = await ApiService().getRequest('/find-by-site-id/$id');
      final locationData = data['data'];
      siteModel = SiteModel.fromJson(locationData);

      setState(() {
        context.read<MarkState>().addMarker(
              Marker(
                markerId: const MarkerId("mark_end"),
                position: LatLng(siteModel!.lat, siteModel!.lng),
              ),
            );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(siteModel?.siteDesc ?? '', style: Theme.of(context).textTheme.headlineMedium),
        leadingIcon: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: () {
            context.read<MarkState>().clearMarkerFinal();
            Navigator.pop(context);
          },
        ),
        icon: null,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                context.watch<SiteNavigatorState>().siteNavigator.siteLocation!.lat,
                context.watch<SiteNavigatorState>().siteNavigator.siteLocation!.lng,
              ),
              zoom: 11.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: context.watch<MarkState>().markers,
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: AddressInfoCard(siteModel: siteModel),
          ),
          Positioned(
            bottom: 30,
            left: 10,
            right: 10,
            child: BottomLocationCard(isLoading: isLoading, siteModel: siteModel),
          ),
        ],
      ),
    );
  }
}

class AddressInfoCard extends StatelessWidget {
  final SiteModel? siteModel;

  const AddressInfoCard({Key? key, required this.siteModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ที่อยู่',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(107, 107, 107, 1)),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.25,
              indent: 5,
              endIndent: 5,
            ),
            Text(
              siteModel?.siteAddress ?? '',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(107, 107, 107, 1)),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomLocationCard extends StatelessWidget {
  final bool isLoading;
  final SiteModel? siteModel;

  const BottomLocationCard({
    Key? key,
    required this.isLoading,
    required this.siteModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isLoading
              ? const CircularProgressIndicator()
              : LocationCard(
                  siteId: siteModel!.siteId,
                  siteDesc: siteModel!.siteDesc,
                  siteAddress: siteModel!.siteAddress,
                  siteTel: siteModel!.siteTel,
                  siteOpenTime: siteModel!.siteOpenTime,
                  siteCloseTime: siteModel!.siteCloseTime,
                  lat: siteModel!.lat,
                  lng: siteModel!.lng,
                  distance: context.watch<SiteNavigatorState>().siteNavigator.distance!,
                  active: true,
                  isNavigator: true,
                ),
        ],
      ),
    );
  }
}
