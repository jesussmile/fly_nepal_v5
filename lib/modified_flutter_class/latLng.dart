import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class LatLng {
  // final Logger _logger = new Logger('latlong2.LatLng');

   double latitude;
   double longitude;

   LatLng(this.latitude, this.longitude)
      : assert(latitude >= -90 && latitude <= 90),
        assert(longitude >= -180 && longitude <= 180);

  double get latitudeInRad => degToRadian(latitude);

  double get longitudeInRad => degToRadian(longitude);

  LatLng.fromJson(Map<String, dynamic> json)
      : latitude = json['coordinates'][1],
        longitude = json['coordinates'][0];

  Map<String, dynamic> toJson() => {
        'coordinates': [longitude, latitude]
      };

  @override
  String toString() =>
      'LatLng(latitude:${NumberFormat("0.0#####").format(latitude)}, '
      'longitude:${NumberFormat("0.0#####").format(longitude)})';

  /// Converts sexagesimal string into a lat/long value
  ///
  ///     final LatLng p1 = new LatLng.fromSexagesimal('''51° 31' 10.11" N, 19° 22' 32.00" W''');
  ///     print("${p1.latitude}, ${p1.longitude}");
  ///     // Shows:
  ///     51.519475, -19.37555556
  ///
  factory LatLng.fromSexagesimal(final String str) {
    double _latitude = 0.0;
    double _longitude = 0.0;
    // try format '''47° 09' 53.57" N, 8° 32' 09.04" E'''
    var splits = str.split(',');
    if (splits.length != 2) {
      // try format '''N 47°08'52.57" E 8°32'09.04"'''
      splits = str.split('E');
      if (splits.length != 2) {
        // try format '''N 47°08'52.57" W 8°32'09.04"'''
        splits = str.split('W');
        if (splits.length != 2) {
          throw 'Unsupported sexagesimal format: $str';
        }
      }
    }
    _latitude = sexagesimal2decimal(splits[0]);
    _longitude = sexagesimal2decimal(splits[1]);
    if (str.contains('S')) {
      _latitude = -_latitude;
    }
    if (str.contains('W')) {
      _longitude = -_longitude;
    }
    return LatLng(_latitude, _longitude);
  }

  /// Converts lat/long values into sexagesimal
  ///
  ///     final LatLng p1 = new LatLng(51.519475, -19.37555556);
  ///
  ///     // Shows: 51° 31' 10.11" N, 19° 22' 32.00" W
  ///     print(p1..toSexagesimal());
  ///
  String toSexagesimal() {
    var latDirection = latitude >= 0 ? 'N' : 'S';
    var lonDirection = longitude >= 0 ? 'E' : 'W';
    return '${decimal2sexagesimal(latitude)} $latDirection, ${decimal2sexagesimal(longitude)} $lonDirection';
  }

  @override
  int get hashCode => latitude.hashCode + longitude.hashCode;

  @override
  bool operator ==(final Object other) =>
      other is LatLng &&
      latitude == other.latitude &&
      longitude == other.longitude;

  LatLng round({final int decimals = 6}) => LatLng(
      _round(latitude, decimals: decimals),
      _round(longitude, decimals: decimals));

  //- private -----------------------------------------------------------------------------------

  /// No qualifier for top level functions in Dart. Had to copy this function
  double _round(final double value, {final int decimals = 6}) =>
      (value * math.pow(10, decimals)).round() / math.pow(10, decimals);
}
