import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bangkok_drugstore_mobile/models/custom_geometry.dart';
import 'package:bangkok_drugstore_mobile/services/api_service.dart';
import 'package:bangkok_drugstore_mobile/states/site_navigator_state.dart';

class LocationCard extends StatelessWidget {
  final String siteId;
  final String siteDesc;
  final String siteAddress;
  final String siteTel;
  final String siteOpenTime;
  final String siteCloseTime;
  final double lat;
  final double lng;
  final int distance;
  final bool active;
  final bool isNavigator;

  const LocationCard({
    super.key,
    required this.siteId,
    required this.siteDesc,
    required this.siteAddress,
    required this.siteTel,
    required this.siteOpenTime,
    required this.siteCloseTime,
    required this.lat,
    required this.lng,
    required this.distance,
    required this.active,
    this.isNavigator = false,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: convertPhoneNumber(phoneNumber),
    );
    await launchUrl(launchUri);
  }

  String getOperatingHours(String openTime, String closeTime) {
    if (openTime == '00:00:00' && closeTime == '00:00:00') {
      return '24 ชม.';
    } else {
      return '${openTime.substring(0, 5)} - ${closeTime.substring(0, 5)}';
    }
  }

  String convertPhoneNumber(String phoneNumber) {
    return phoneNumber
        .replaceAll(' ', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceFirst('0', '+66')
        .replaceAll('ต่อ', ',');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 12,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(context),
            const Divider(
              color: Colors.grey,
              thickness: 0.25,
              indent: 5,
              endIndent: 5,
            ),
            buildButtons(context),
          ],
        ),
      ),
    );
  }

  Row buildHeader(BuildContext context) {
    final distanceInKm = (distance / 1000).toStringAsFixed(2);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/icons/mark_blue.svg',
          width: 32.0,
          height: 32.0,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDetailRow('สาขา : ', siteDesc, isBold: true),
              const SizedBox(height: 5),
              buildDetailRow('ระยะทางจากที่นี่ : ', '$distanceInKm กม.', isBold: true),
              const SizedBox(height: 5),
              buildOperatingHoursRow(),
            ],
          ),
        ),
      ],
    );
  }

  Row buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              fontFamily: 'Prompt',
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Prompt',
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Row buildOperatingHoursRow() {
    return Row(
      children: [
        const Expanded(
          flex: 1,
          child: Text(
            'เวลาปิดเปิดร้าน : ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              fontFamily: 'Prompt',
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: RichText(
            text: TextSpan(
              children: [
                if (active)
                  TextSpan(
                    text: getOperatingHours(siteOpenTime, siteCloseTime),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Prompt',
                      color: Colors.black,
                    ),
                  )
                else ...[
                  const TextSpan(
                    text: 'ปิด',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Prompt',
                      color: Colors.red,
                    ),
                  ),
                  TextSpan(
                    text: ' (เปิด ${getOperatingHours(siteOpenTime, siteCloseTime)})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Prompt',
                      color: Colors.black,
                    ),
                  ),
                ]
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Row buildButtons(BuildContext context) {
    return Row(
      children: [
        buildPhoneButton(),
        const SizedBox(width: 10),
        buildNavigateButton(context),
      ],
    );
  }

  Expanded buildPhoneButton() {
    return Expanded(
      flex: 1,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16),
          side: BorderSide(
            color: active ? Colors.blue : const Color.fromRGBO(161, 213, 246, 1),
          ),
          disabledBackgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        ),
        onPressed: active ? () => _makePhoneCall(siteTel) : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              active ? 'assets/icons/phone.svg' : 'assets/icons/phone_disable.svg',
              width: 16.0,
              height: 16.0,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                siteTel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Prompt',
                  color: active ? Colors.blue : const Color.fromRGBO(161, 213, 246, 1),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded buildNavigateButton(BuildContext context) {
    return Expanded(
      flex: 1,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(0, 179, 240, 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16),
          disabledBackgroundColor: const Color.fromRGBO(161, 213, 246, 1),
        ),
        onPressed: active
            ? () {
                if (!isNavigator) {
                  context.read<SiteNavigatorState>().setSite(
                        siteId,
                        CustomLocation(lat: lat, lng: lng),
                        distance,
                      );
                  Navigator.pushNamed(context, '/map-navigate');
                } else {
                  final siteNavigatorState = context.read<SiteNavigatorState>();
                  ApiService().deepLinkGoogleMap(
                        siteNavigatorState.siteNavigator.myLocation!.lat,
                        siteNavigatorState.siteNavigator.myLocation!.lng,
                        lat,
                        lng,
                      );
                }
              }
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              !isNavigator ? 'assets/icons/map.svg' : 'assets/icons/send.svg',
              width: 16.0,
              height: 16.0,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                !isNavigator ? 'แผนที่สาขา' : 'นำทาง',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Prompt',
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
