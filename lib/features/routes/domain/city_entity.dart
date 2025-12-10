import 'package:equatable/equatable.dart';

/// City entity matching the cities table
class CityEntity extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final bool isActive;

  const CityEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.isActive,
  });

  factory CityEntity.fromJson(Map<String, dynamic> json) {
    return CityEntity(
      id: json['id'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, nameAr, nameEn, isActive];
}
