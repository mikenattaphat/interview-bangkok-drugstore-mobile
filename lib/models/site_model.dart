class SiteModel {
  final String siteId;
  final String siteDesc;
  final String siteAddress;
  final String siteTel;
  final String siteOpenTime;
  final String siteCloseTime;
  final double lat;
  final double lng;
  final String distance;
  final String active;

  SiteModel({
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
  });

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    return SiteModel(
      siteId: json['site_id'],
      siteDesc: json['site_desc'],
      siteAddress: json['site_address'],
      siteTel: json['site_tel'],
      siteOpenTime: json['site_open_time'],
      siteCloseTime: json['site_close_time'],
      lat: json['location']['coordinates'][1].toDouble(),
      lng: json['location']['coordinates'][0].toDouble(),
      distance: json['distance'].toString(),
      active: json['active'].toString(),
    );
  }
}
