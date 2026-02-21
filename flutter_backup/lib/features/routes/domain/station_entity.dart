import 'package:equatable/equatable.dart';
import 'package:dashboard_fi_el_sekka/features/routes/domain/university_entity.dart';

enum StationType {
  pickup,
  dropoff,
  both;

  static StationType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pickup':
        return StationType.pickup;
      case 'dropoff':
        return StationType.dropoff;
      case 'both':
        return StationType.both;
      default:
        return StationType.both;
    }
  }

  String get displayName {
    switch (this) {
      case StationType.pickup:
        return 'نقطة صعود';
      case StationType.dropoff:
        return 'نقطة نزول';
      case StationType.both:
        return 'صعود ونزول';
    }
  }
}

/// Station entity matching the stations table
class StationEntity extends Equatable {
  final String id;
  final String cityId;
  final String? cityName;
  final String nameAr;
  final String nameEn;
  final LocationData location;
  final StationType stationType;
  final bool isActive;

  const StationEntity({
    required this.id,
    required this.cityId,
    this.cityName,
    required this.nameAr,
    required this.nameEn,
    required this.location,
    required this.stationType,
    required this.isActive,
  });

  factory StationEntity.fromJson(Map<String, dynamic> json) {
    return StationEntity(
      id: json['id'] as String? ?? '',
      cityId: json['city_id'] as String? ?? '',
      cityName: json['cities']?['name_ar'] as String?,
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      location: LocationData.fromJson(
        json['location'] as Map<String, dynamic>?,
      ),
      stationType: StationType.fromString(json['station_type'] as String?),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn;

  @override
  List<Object?> get props => [
    id,
    cityId,
    cityName,
    nameAr,
    nameEn,
    stationType,
    isActive,
  ];
}
