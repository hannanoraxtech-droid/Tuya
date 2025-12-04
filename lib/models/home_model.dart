class HomeModel {
  final int homeId;
  final String name;
  final String geoName;
  final double latitude;
  final double longitude;
  final bool isAdmin;
  final int roomCount;
  final int deviceCount;
  final int? groupCount;

  HomeModel({
    required this.homeId,
    required this.name,
    this.geoName = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.isAdmin = false,
    this.roomCount = 0,
    this.deviceCount = 0,
    this.groupCount,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      homeId: json['homeId'] as int,
      name: json['name'] as String,
      geoName: json['geoName'] as String? ?? '',
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : 0.0,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : 0.0,
      isAdmin: json['admin'] as bool? ?? false,
      roomCount: json['roomCount'] as int? ?? 0,
      deviceCount: json['deviceCount'] as int? ?? 0,
      groupCount: json['groupCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'homeId': homeId,
      'name': name,
      'geoName': geoName,
      'latitude': latitude,
      'longitude': longitude,
      'admin': isAdmin,
      'roomCount': roomCount,
      'deviceCount': deviceCount,
      'groupCount': groupCount,
    };
  }

  HomeModel copyWith({
    int? homeId,
    String? name,
    String? geoName,
    double? latitude,
    double? longitude,
    bool? isAdmin,
    int? roomCount,
    int? deviceCount,
    int? groupCount,
  }) {
    return HomeModel(
      homeId: homeId ?? this.homeId,
      name: name ?? this.name,
      geoName: geoName ?? this.geoName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isAdmin: isAdmin ?? this.isAdmin,
      roomCount: roomCount ?? this.roomCount,
      deviceCount: deviceCount ?? this.deviceCount,
      groupCount: groupCount ?? this.groupCount,
    );
  }
}
