class Site {
  final String siteId;
  final String siteDesc;
  final String siteAddress;
  final String siteTel;
  final List<double> location;
  final String siteCloseTime;
  final String siteOpenTime;
  final bool active;
  final int distance;

  Site({
    required this.siteId,
    required this.siteDesc,
    required this.siteAddress,
    required this.siteTel,
    required this.location,
    required this.siteCloseTime,
    required this.siteOpenTime,
    required this.active,
    required this.distance,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      siteId: json['site_id'],
      siteDesc: json['site_desc'],
      siteAddress: json['site_address'],
      siteTel: json['site_tel'],
      location: List<double>.from(json['location']),
      siteCloseTime: json['site_close_time'],
      siteOpenTime: json['site_open_time'],
      active: json['active'],
      distance: json['distance'],
    );
  }
}
