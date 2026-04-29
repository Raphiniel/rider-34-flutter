import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  /// Fetches a route from [origin] to [destination] with optional [waypoints].
  /// Returns a list of [LatLng] points forming the polyline.
  static Future<Map<String, dynamic>?> fetchRoute(
    LatLng origin,
    LatLng destination, {
    List<LatLng> waypoints = const [],
  }) async {
    final List<LatLng> allCoords = [origin, ...waypoints, destination];
    final String coordsString = allCoords
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');

    final url = Uri.parse(
      '$_baseUrl/$coordsString?overview=full&geometries=polyline&steps=false',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final String encodedPolyline = route['geometry'];
          final double distance = (route['distance'] as num).toDouble() / 1000.0; // km
          final double duration = (route['duration'] as num).toDouble() / 60.0; // min

          return {
            'points': _decodePolyline(encodedPolyline),
            'distance': distance,
            'duration': duration,
          };
        }
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
    return null;
  }

  /// Decodes a polyline string into a list of [LatLng].
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
