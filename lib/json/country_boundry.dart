// import 'package:flutter/material.dart';

// Future<void> loadGeoJson() async {
//     // Load GeoJSON data from asset file
//     String data = await DefaultAssetBundle.of(context)
//         .loadString('assets/countries.geojson');
//     Map<String, dynamic> geoJson = json.decode(data);

//     // Extract coordinates from GeoJSON data and create LatLng list
//     List<dynamic> coordinates =
//         geoJson['features'][0]['geometry']['coordinates'][0];
//     border = coordinates
//         .map((coordinate) => LatLng(coordinate[1], coordinate[0]))
//         .toList();

//     setState(() {});
//   }