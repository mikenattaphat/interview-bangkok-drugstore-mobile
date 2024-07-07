import 'dart:async';
import 'package:bangkok_drugstore_mobile/models/site_location.dart';
import 'package:bangkok_drugstore_mobile/services/api_service.dart';
import 'package:bangkok_drugstore_mobile/states/mark_state.dart';
import 'package:bangkok_drugstore_mobile/states/site_navigator_state.dart';
import 'package:bangkok_drugstore_mobile/widgets/custom_app_bar.dart';
import 'package:bangkok_drugstore_mobile/widgets/location_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SiteListScreen extends StatefulWidget {
  const SiteListScreen({Key? key}) : super(key: key);

  @override
  _SiteListScreenState createState() => _SiteListScreenState();
}

class _SiteListScreenState extends State<SiteListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Site> locations = [];
  bool isLoadingMore = false;
  int currentPage = 1;
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (locations.isEmpty) {
      fetchApiNearbyPharmacy(currentPage);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchApiNearbyPharmacy(int page) async {
    if (isLoadingMore) return;
    
    setState(() {
      isLoadingMore = true;
    });

    try {
      final data = await ApiService().postRequest('/nearby-pharmacy', {
        "lat": Provider.of<SiteNavigatorState>(context, listen: false).siteNavigator.myLocation!.lat,
        "lng": Provider.of<SiteNavigatorState>(context, listen: false).siteNavigator.myLocation!.lng,
        "pagination": {"page": page, "limit": 10},
        "site_desc": _searchQuery,
      });

      final items = data['data'] as List<dynamic>;

      setState(() {
        if (page == 1) {
          locations.clear();
        }
        locations.addAll(items.map((location) => Site.fromJson(location)).toList());
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
      throw Exception('Failed to load items: $e');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 500 && !isLoadingMore) {
      currentPage++;
      fetchApiNearbyPharmacy(currentPage);
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value;
        currentPage = 1;
      });
      fetchApiNearbyPharmacy(currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'ค้นหาสาขา',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        icon: const IconThemeData(color: Colors.blue),
        leadingIcon: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: () {
            context.read<MarkState>().clearMarkerFinal();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ค้นหาสาขา',
                    prefixIcon: Container(
                      padding: const EdgeInsets.only(left: 15.0, right: 10.0),
                      child: SvgPicture.asset(
                        'assets/icons/search.svg',
                        width: 24.0,
                        height: 24.0,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    hintStyle: const TextStyle(
                      color: Color(0xFFABABAB),
                      fontSize: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(color: Color(0xFFABABAB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(color: Color(0xFFABABAB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(color: Color(0xFFABABAB)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  ),
                  onChanged: _onSearchChanged,
                ),
                Expanded(
                  child: locations.isEmpty && !isLoadingMore
                      ? const Center(child: Text('ไม่พบร้านยาใกล้เคียง'))
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: locations.length + (isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == locations.length) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final location = locations[index];
                            return LocationCard(
                              siteId: location.siteId,
                              siteDesc: location.siteDesc,
                              siteAddress: location.siteAddress,
                              siteTel: location.siteTel,
                              siteOpenTime: location.siteOpenTime,
                              siteCloseTime: location.siteCloseTime,
                              lat: location.location[1],
                              lng: location.location[0],
                              distance: location.distance,
                              active: location.active,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
