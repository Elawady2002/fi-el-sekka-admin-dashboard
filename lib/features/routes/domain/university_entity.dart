import 'package:equatable/equatable.dart';

/// Location data structure
class LocationData {
  final double? lat;
  final double? lng;
  final String? address;

  const LocationData({this.lat, this.lng, this.address});

  factory LocationData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LocationData();
    return LocationData(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      address: json['address'] as String?,
    );
  }

  bool get hasCoordinates => lat != null && lng != null;
}

/// University entity matching the universities table
class UniversityEntity extends Equatable {
  final String id;
  final String cityId;
  final String? cityName;
  final String nameAr;
  final String nameEn;
  final LocationData location;
  final bool isActive;

  const UniversityEntity({
    required this.id,
    required this.cityId,
    this.cityName,
    required this.nameAr,
    required this.nameEn,
    required this.location,
    required this.isActive,
  });

  factory UniversityEntity.fromJson(Map<String, dynamic> json) {
    return UniversityEntity(
      id: json['id'] as String? ?? '',
      cityId: json['city_id'] as String? ?? '',
      cityName: json['cities']?['name_ar'] as String?,
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      location: LocationData.fromJson(
        json['location'] as Map<String, dynamic>?,
      ),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, cityId, cityName, nameAr, nameEn, isActive];
}
