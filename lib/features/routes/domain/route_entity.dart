import 'package:equatable/equatable.dart';

/// Route entity matching the routes table
class RouteEntity extends Equatable {
  final String id;
  final String universityId;
  final String? universityName;
  final String routeNameAr;
  final String routeNameEn;
  final String routeCode;
  final List<String> stationsOrder;
  final bool isActive;

  const RouteEntity({
    required this.id,
    required this.universityId,
    this.universityName,
    required this.routeNameAr,
    required this.routeNameEn,
    required this.routeCode,
    required this.stationsOrder,
    required this.isActive,
  });

  factory RouteEntity.fromJson(Map<String, dynamic> json) {
    List<String> parseStationsOrder(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return RouteEntity(
      id: json['id'] as String? ?? '',
      universityId: json['university_id'] as String? ?? '',
      universityName: json['universities']?['name_ar'] as String?,
      routeNameAr: json['route_name_ar'] as String? ?? '',
      routeNameEn: json['route_name_en'] as String? ?? '',
      routeCode: json['route_code'] as String? ?? '',
      stationsOrder: parseStationsOrder(json['stations_order']),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String get displayName => routeNameAr.isNotEmpty ? routeNameAr : routeNameEn;

  int get stationCount => stationsOrder.length;

  @override
  List<Object?> get props => [
    id,
    universityId,
    universityName,
    routeNameAr,
    routeNameEn,
    routeCode,
    stationsOrder,
    isActive,
  ];
}
