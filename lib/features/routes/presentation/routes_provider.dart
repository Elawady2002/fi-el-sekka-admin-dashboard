import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dashboard_fi_el_sekka/features/routes/domain/city_entity.dart';
import 'package:dashboard_fi_el_sekka/features/routes/domain/university_entity.dart';
import 'package:dashboard_fi_el_sekka/features/routes/domain/station_entity.dart';
import 'package:dashboard_fi_el_sekka/features/routes/domain/route_entity.dart';

/// Helper function to get headers for API calls
Map<String, String> _getHeaders() {
  final serviceKey =
      dotenv.env['SUPABASE_SERVICE_KEY'] ?? dotenv.env['SUPABASE_ANON_KEY'];
  return {
    'apikey': serviceKey ?? '',
    'Authorization': 'Bearer ${serviceKey ?? ''}',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };
}

String get _supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

/// Provider for fetching all cities
final citiesProvider = FutureProvider<List<CityEntity>>((ref) async {
  try {
    debugPrint('🏙️ Fetching cities from database...');

    final response = await http.get(
      Uri.parse('$_supabaseUrl/rest/v1/cities?select=*&order=name_ar'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch cities: ${response.body}');
    }

    final responseList = json.decode(response.body) as List? ?? [];
    final cities = responseList
        .map((json) => CityEntity.fromJson(json as Map<String, dynamic>))
        .toList();

    debugPrint('🏙️ Fetched ${cities.length} cities');
    return cities;
  } catch (e) {
    debugPrint('Error fetching cities: $e');
    rethrow;
  }
});

/// Provider for fetching all universities with city data
final universitiesProvider = FutureProvider<List<UniversityEntity>>((
  ref,
) async {
  try {
    debugPrint('🎓 Fetching universities from database...');

    final response = await http.get(
      Uri.parse(
        '$_supabaseUrl/rest/v1/universities?select=*,cities(name_ar,name_en)&order=name_ar',
      ),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch universities: ${response.body}');
    }

    final responseList = json.decode(response.body) as List? ?? [];
    final universities = responseList
        .map((json) => UniversityEntity.fromJson(json as Map<String, dynamic>))
        .toList();

    debugPrint('🎓 Fetched ${universities.length} universities');
    return universities;
  } catch (e) {
    debugPrint('Error fetching universities: $e');
    rethrow;
  }
});

/// Provider for fetching all stations with city data
final stationsProvider = FutureProvider<List<StationEntity>>((ref) async {
  try {
    debugPrint('🚏 Fetching stations from database...');

    final response = await http.get(
      Uri.parse(
        '$_supabaseUrl/rest/v1/stations?select=*,cities(name_ar,name_en)&order=name_ar',
      ),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch stations: ${response.body}');
    }

    final responseList = json.decode(response.body) as List? ?? [];
    final stations = responseList
        .map((json) => StationEntity.fromJson(json as Map<String, dynamic>))
        .toList();

    debugPrint('🚏 Fetched ${stations.length} stations');
    return stations;
  } catch (e) {
    debugPrint('Error fetching stations: $e');
    rethrow;
  }
});

/// Provider for fetching all routes with university data
final routesProvider = FutureProvider<List<RouteEntity>>((ref) async {
  try {
    debugPrint('🛤️ Fetching routes from database...');

    final response = await http.get(
      Uri.parse(
        '$_supabaseUrl/rest/v1/routes?select=*,universities(name_ar,name_en)&order=route_name_ar',
      ),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch routes: ${response.body}');
    }

    final responseList = json.decode(response.body) as List? ?? [];
    final routes = responseList
        .map((json) => RouteEntity.fromJson(json as Map<String, dynamic>))
        .toList();

    debugPrint('🛤️ Fetched ${routes.length} routes');
    return routes;
  } catch (e) {
    debugPrint('Error fetching routes: $e');
    rethrow;
  }
});

/// Stats for routes and locations
class RoutesLocationStats {
  final int totalCities;
  final int totalUniversities;
  final int totalStations;
  final int totalRoutes;
  final int activeCities;
  final int activeUniversities;
  final int activeStations;
  final int activeRoutes;

  const RoutesLocationStats({
    required this.totalCities,
    required this.totalUniversities,
    required this.totalStations,
    required this.totalRoutes,
    required this.activeCities,
    required this.activeUniversities,
    required this.activeStations,
    required this.activeRoutes,
  });
}

final routesLocationStatsProvider = FutureProvider<RoutesLocationStats>((
  ref,
) async {
  final cities = await ref.watch(citiesProvider.future);
  final universities = await ref.watch(universitiesProvider.future);
  final stations = await ref.watch(stationsProvider.future);
  final routes = await ref.watch(routesProvider.future);

  return RoutesLocationStats(
    totalCities: cities.length,
    totalUniversities: universities.length,
    totalStations: stations.length,
    totalRoutes: routes.length,
    activeCities: cities.where((c) => c.isActive).length,
    activeUniversities: universities.where((u) => u.isActive).length,
    activeStations: stations.where((s) => s.isActive).length,
    activeRoutes: routes.where((r) => r.isActive).length,
  );
});

// ==================== CRUD Functions ====================

/// Add a new city
Future<bool> addCity({
  required String nameAr,
  required String nameEn,
  bool isActive = true,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$_supabaseUrl/rest/v1/cities'),
      headers: _getHeaders(),
      body: json.encode({
        'name_ar': nameAr,
        'name_en': nameEn,
        'is_active': isActive,
      }),
    );

    if (response.statusCode == 201) {
      debugPrint('✅ City added successfully');
      return true;
    } else {
      debugPrint('❌ Failed to add city: ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('❌ Error adding city: $e');
    return false;
  }
}

/// Add a new university
Future<bool> addUniversity({
  required String nameAr,
  required String nameEn,
  required String cityId,
  double? lat,
  double? lng,
  bool isActive = true,
}) async {
  try {
    // Default location to 0,0 if not provided (required by DB)
    final Map<String, dynamic> body = {
      'name_ar': nameAr,
      'name_en': nameEn,
      'city_id': cityId,
      'is_active': isActive,
      'location': {'lat': lat ?? 0.0, 'lng': lng ?? 0.0},
    };

    final response = await http.post(
      Uri.parse('$_supabaseUrl/rest/v1/universities'),
      headers: _getHeaders(),
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      debugPrint('✅ University added successfully');
      return true;
    } else {
      debugPrint('❌ Failed to add university: ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('❌ Error adding university: $e');
    return false;
  }
}

/// Add a new station
Future<bool> addStation({
  required String nameAr,
  required String nameEn,
  required String cityId,
  String stationType = 'both',
  double? lat,
  double? lng,
  bool isActive = true,
}) async {
  try {
    // Default location to 0,0 if not provided (required by DB)
    final Map<String, dynamic> body = {
      'name_ar': nameAr,
      'name_en': nameEn,
      'city_id': cityId,
      'station_type': stationType,
      'is_active': isActive,
      'location': {'lat': lat ?? 0.0, 'lng': lng ?? 0.0},
    };

    final response = await http.post(
      Uri.parse('$_supabaseUrl/rest/v1/stations'),
      headers: _getHeaders(),
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      debugPrint('✅ Station added successfully');
      return true;
    } else {
      debugPrint('❌ Failed to add station: ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('❌ Error adding station: $e');
    return false;
  }
}

/// Add a new route
Future<bool> addRoute({
  required String routeNameAr,
  required String routeNameEn,
  required String routeCode,
  required String universityId,
  List<String> stationsOrder = const [],
  bool isActive = true,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$_supabaseUrl/rest/v1/routes'),
      headers: _getHeaders(),
      body: json.encode({
        'route_name_ar': routeNameAr,
        'route_name_en': routeNameEn,
        'route_code': routeCode,
        'university_id': universityId,
        'stations_order': stationsOrder,
        'is_active': isActive,
      }),
    );

    if (response.statusCode == 201) {
      debugPrint('✅ Route added successfully');
      return true;
    } else {
      debugPrint('❌ Failed to add route: ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('❌ Error adding route: $e');
    return false;
  }
}

/// Update a station's type
Future<bool> updateStationType({
  required String stationId,
  required String newType,
}) async {
  try {
    final response = await http.patch(
      Uri.parse('$_supabaseUrl/rest/v1/stations?id=eq.$stationId'),
      headers: _getHeaders(),
      body: json.encode({'station_type': newType}),
    );

    if (response.statusCode == 200) {
      debugPrint('✅ Station type updated to $newType');
      return true;
    } else {
      debugPrint('❌ Failed to update station type: ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('❌ Error updating station type: $e');
    return false;
  }
}
