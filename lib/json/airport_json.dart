// import 'dart:convert';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:fly_nepal/screens/providers/airport_list_provider.dart';
// import 'package:fly_nepal/screens/widgets/airport_marker_widget.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:provider/provider.dart';

// class AirportMarkers {
//   static Future<void> loadMarkers(BuildContext context) async {
//     List<Marker> airportMarkers = [];

//     markerWidth = 20;
//     markerHeight = 0;

//     // Load the JSON file containing the markers
//     final String jsonString =
//         await rootBundle.loadString('assets/airport_markers.json');

//     // Decode the JSON data into a List of Maps
//     final List<dynamic> jsonData = json.decode(jsonString);

//     // Create a List of Markers from the JSON data
//     airportMarkers = jsonData.map((data) {
//       final double latitude = data['point']['latitude'];
//       final double longitude = data['point']['longitude'];
//       final String text = data['text'];

//       return Marker(
//         width: markerWidth,
//         height: markerHeight,
//         point: LatLng(latitude, longitude),
//         builder: (ctx) => MarkerTap(str: text),
//       );
//     }).toList();

//     // Provider.of<MarkerListProvider>(context, listen: false)
//     //     .setAirportMarkers(airportMarkers);
//   }
// }
