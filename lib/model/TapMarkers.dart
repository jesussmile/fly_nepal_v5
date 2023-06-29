import 'package:fly_nepal/modified_flutter_class/MarkerX.dart';

class TapMarkers {
  final String code;
  final String? name;
  final double latitude;
  final double longitude;
  final double? elevation;

  TapMarkers({
    required this.code,
    this.name,
    required this.latitude,
    required this.longitude,
    this.elevation,
  });

  static List<TapMarkers> allMarkers = [];

  static void addMarkers(List<MarkerX> markers) {
    for (final marker in markers) {
      final tapMarker = TapMarkers(
        code: marker.identifier,
        name:
            marker.name ?? marker.name, // replace with actual name if available
        latitude: marker.point.latitude,
        longitude: marker.point.longitude,
        elevation: null, // replace with actual elevation if available
      );
      if (!allMarkers.contains(tapMarker)) {
        allMarkers.add(tapMarker);
      }
    }
  }

  @override
  bool operator ==(other) {
    return other is TapMarkers &&
        code == other.code &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        elevation == other.elevation;
  }

  @override
  int get hashCode =>
      code.hashCode ^
      name.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      elevation.hashCode;
}
