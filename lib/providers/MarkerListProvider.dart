import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:fly_nepal/model/all_markers.dart';
import 'package:fly_nepal/model/chip_modal.dart';
import 'package:fly_nepal/providers/provider_service.dart';
import 'package:fly_nepal/services/assetFile.dart';
import 'package:fly_nepal/services/data.dart';
import 'package:fly_nepal/modified_flutter_class/polyLineX.dart';
import 'package:fly_nepal/widgets/way_point.marker.dart';
import 'package:fly_nepal/modified_flutter_class/MarkerX.dart';
//import 'package:fly_nepal/test_markers/my_markers.dart' as custMarker;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MarkerListProvider extends ChangeNotifier {
  List<List<PolylineX>> userPolyline = [];
  List<String> allAirports = [];
  List<MarkerX> airportMarkers = [];
  List<List<LatLng>> borders = [];
  List<MarkerX> navAidMarkers = [];
  List<MarkerX> wayPointsMarkers = [];
  //List<Marker> wayPointRouteMarkers = [];
  List<MarkerX> reportingFixMarkers = [];
  List<MarkerX> reportingPointsMarkers = [];
  List<LatLng> firPolyline = [];
  List<List<LatLng>> airwayPolyLine = [];
  List<AllMarkers> allMarkersList = [];
  bool mapReady = false;
  late LatLngBounds? latLngB = LatLngBounds(LatLng(0, 0), LatLng(0, 0));
  List<MarkerX> tapMarkersList = [];
  List<ChipModel> chipList = [];
  List<Fix> fix = []; //fordebug
  List<LatLng> goAroundLatLng = [];
  List<List<LatLng>> totalUserLatLng = [];
  List<LatLng> sidFixLatlng = [];
  List<LatLng> sidLatLng = [];
  List<LatLng> sidTransitionFixesLatLng = [];
  List<LatLng> starLatLng = [];
  List<LatLng> userLatLng = [];
  List<LatLng> appFixLatLng = [];
  List<LatLng> appFixTransLatLng = [];
  List<Marker> customMarker = [];
  String movingChip = "";
  dynamic selectedChip;

  void movingChipName(String movingChipName) {
    movingChip = movingChipName;
    notifyListeners();
  }

  void addFix(List<Fix> fixy) {
    //fordebug
    fix = fixy;
    notifyListeners();
  }

  void clear() {
    //  var provider = of<MarkerListProvider>(context, listen: false);
    //  setState(() {
    chipList.clear();
    totalUserLatLng.clear();
    sidFixLatlng.clear(); // = [];
    sidLatLng.clear(); // = [];
    sidTransitionFixesLatLng.clear(); // = [];
    starLatLng.clear(); // = [];
    userLatLng.clear(); // = [];
    appFixLatLng.clear(); // = [];
    appFixTransLatLng.clear(); // = [];
    goAroundLatLng.clear();

    //List<Marker> customMarker = [];
    // customRoute.clear();
    customMarker.clear();
    notifyListeners();
  }

  void setSelectedChip(ChipModel chip) {
    selectedChip = chip;
    notifyListeners();
  }

  void removeCustomMarker(String name) {
    customMarker.removeWhere((element) {
      final keyString = element.key.toString();
      final extractedName = keyString.substring(
          keyString.indexOf("<'") + 2, keyString.lastIndexOf("'>"));
      return extractedName == name;
    });
    notifyListeners();
  }

  Future<void> loadCustomMarker(
      double latitude, double longitude, String identifier) async {
    // print(identifier);
    bool isDuplicate = customMarker.any((marker) {
      // print(marker.key.toString().replaceAll("[<'", "").replaceAll("'>]", ""));
      return marker.point.latitude == latitude &&
          marker.point.longitude == longitude &&
          marker.key.toString().replaceAll("[<'", "").replaceAll("'>]", "") ==
              identifier;
    });
    if (!isDuplicate) {
      double markerWidth = 85;
      double markerHeight = 16;
      customMarker.add(Marker(
        key: ValueKey<String>(identifier),
        anchorPos: AnchorPos.align(AnchorAlign.right),
        width: markerWidth,
        height: markerHeight,
        point: LatLng(latitude, longitude),
        builder: (ctx) => WayPointMarkerTap(str: identifier),
      ));
      notifyListeners();
    }
  }

  void printTotalUserLatLng() {
    print(totalUserLatLng.length);
    List<String> apName = [];
    for (List<LatLng> latlngL in totalUserLatLng) {
      print(latlngL);
    }
  }

  void clearFix() {
    fix.clear();
  }

  void printFromFix() {
    print(totalUserLatLng.length);
    List<String> apName = [];
    for (List<LatLng> latlngL in totalUserLatLng) {
      // print(latlngL);
      for (int i = 0; i < latlngL.length; i++) {
        for (var element in fix) {
          if (element.lat == latlngL[i].latitude) {
            apName.add(element.name);
          }
        }
      }
      print(apName);
    }
  }

  void addGoAround(List<LatLng> value) {
    goAroundLatLng.addAll(value);
  }

  void addStar(List<LatLng> value) {
    starLatLng.addAll(value);
    //some times the user may start from approach instead of sid
    if (appFixLatLng.isNotEmpty && appFixTransLatLng.isNotEmpty) {
      totalUserLatLng.insert(totalUserLatLng.length - 2, starLatLng);
    } else {
      totalUserLatLng.insert(totalUserLatLng.length - 1, starLatLng);
    }

    notifyListeners();
  }

  void removeStar() {
    totalUserLatLng.remove(starLatLng);
    removeMarkers(appFixTransLatLng);
    removeMarkers(starLatLng);
    starLatLng.clear();
    appFixTransLatLng.clear();
    notifyListeners();
  }

  void addAppFix(List<LatLng> value) {
    appFixLatLng.addAll(value);
    notifyListeners();
  }

  void addAppFixTrans(List<LatLng> value) {
    appFixTransLatLng.addAll(value);
    addApproach();
    notifyListeners();
  }

  void addApproach() {
    totalUserLatLng.removeLast();
    totalUserLatLng.add(appFixTransLatLng);
    totalUserLatLng.add(appFixLatLng);
    notifyListeners();
  }

  void removeApproach() {
    totalUserLatLng.removeAt(totalUserLatLng.indexOf(appFixTransLatLng));
    totalUserLatLng.removeAt(totalUserLatLng.indexOf(appFixLatLng));
    if (allAirports.contains(chipList.last.name)) {
      chipList.removeLast();
    }
    //removeMarkers(appFixTransLatLng);
    removeMarkers(appFixLatLng);
    removeMarkers(goAroundLatLng);
    goAroundLatLng.clear();
    appFixLatLng.clear();

    notifyListeners();
  }

  void addSidFix(List<LatLng> value) {
    sidFixLatlng.addAll(value);
    sidLatLng.addAll(sidFixLatlng);
    // printFromFix();
    notifyListeners();
    // totalCustomLatlng(); // Call the method to update totalUserLatLng
  }

  void addSidFixTrans(List<LatLng> value) {
    sidTransitionFixesLatLng.addAll(value);
    sidLatLng.addAll(sidTransitionFixesLatLng);
    addSid();
    notifyListeners();
  }

  void addSid() {
    if (totalUserLatLng.length > 1) {
      totalUserLatLng.insert(1, sidLatLng);
    } else {
      // sometimes the user may add sid later
      totalUserLatLng.add(sidLatLng);
    }
    notifyListeners();
    // printFromFix();
  }

  void reorder(int oldIndex, int newIndex) {
    ChipModel row = chipList.removeAt(oldIndex);
    chipList.insert(newIndex, row);
    List<LatLng> listLatLng = totalUserLatLng.removeAt(oldIndex);
    totalUserLatLng.insert(newIndex, listLatLng);
    notifyListeners();
  }

  void removeSidL() {
    totalUserLatLng.removeAt(totalUserLatLng.indexOf(sidLatLng));

    removeMarkers(sidFixLatlng);

    sidLatLng.clear;
    notifyListeners();
  }

  void removeMarkers(List<LatLng> listLatLng) {
    for (LatLng l in listLatLng) {
      for (Marker m in customMarker) {
        if (m.point.latitude == l.latitude) {
          customMarker.remove(m);
        }
      }
    }
  }

  void removeSidFixTrans() {
    totalUserLatLng.removeAt(totalUserLatLng.indexOf(sidTransitionFixesLatLng));
    removeMarkers(sidTransitionFixesLatLng);
    sidTransitionFixesLatLng.clear();
    notifyListeners();
  }

  void userLatL(LatLng value) {
    List<LatLng> x = [];
    x.add(value);
    totalUserLatLng.add(x);
    notifyListeners();
  }

  void addChips(String id, String name, String type,
      {LatLng? latLng, List<LatLng>? listLatLng}) {
    if (chipList.length > 1 && type == 'sid') {
      chipList.insert(
          // insert sid as the second item if added later
          1,
          ChipModel(
            id: id,
            name: name,
            latLng: latLng,
            listLatLng: listLatLng,
            type: type,
          ));
    } else if (chipList.length > 1 && type == 'star') {
      if (appFixLatLng.isNotEmpty && appFixTransLatLng.isNotEmpty) {
        chipList.insert(
            chipList.length - 2,
            ChipModel(
              id: id,
              name: name,
              latLng: latLng,
              listLatLng: listLatLng,
              type: type,
            ));
      } else {
        chipList.insert(
            // insert sid as the second item if added later
            2,
            ChipModel(
              id: id,
              name: name,
              latLng: latLng,
              listLatLng: listLatLng,
              type: type,
            ));
      }
    } else if (chipList.length > 1 && type == 'approach') {
      print('chip approach');
      chipList.insert(
          // insert sid as the second item if added later
          chipList.length - 1,
          ChipModel(
            id: id,
            name: name,
            latLng: latLng,
            listLatLng: listLatLng,
            type: type,
          ));
    } else {
      chipList.add(ChipModel(
        id: id,
        name: name,
        latLng: latLng,
        listLatLng: listLatLng,
        type: type,
      ));
    }
    notifyListeners();
  }

  void addTapMarkers(List<MarkerX> tapMarkers) {
    tapMarkersList = tapMarkers;
    notifyListeners();
  }

  double mapZoom = 7;
  void setZoom(double zoom, LatLngBounds? latLngBounds) {
    mapZoom = zoom;
    latLngB = latLngBounds;
    notifyListeners();
  }

  Future<void> loadWayPointsMarkers() async {
    double markerWidth = 5;
    double markerHeight = 5;
    const width = 3.0, height = 3.0;
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;
    const textStyle = TextStyle(
      fontSize: 10,
      //fontFamily: 'GLOUCEST',
      color: Colors.white,
      backgroundColor: Color.fromARGB(115, 34, 32,
          32), // Add this line to set the background color to white
      letterSpacing: 1,
    );
    // Load the JSON file containing the markers
    final String jsonString =
        await rootBundle.loadString('assets/Waypoints.json');
    // Decode the JSON data into a List of Maps
    final List<dynamic> jsonData = await json.decode(jsonString);
    // Create a List of Markers from the JSON data
    List<MarkerX> wayPointRouteM = jsonData.map((data) {
      final String identifier = data["identifier"];
      final double latitude = data['latitude'];
      final double longitude = data['longitude'];
      final String countryCode = data['country_code'];
      final textSpan = TextSpan(
        text: identifier,
        style: textStyle,
      );
      final textPainter =
          TextPainter(text: textSpan, textDirection: TextDirection.ltr)
            ..textScaleFactor = 1.0;
      AllMarkers allMarkers = AllMarkers(
        code: identifier,
        name: countryCode,
        latitude: latitude,
        longitude: longitude,
      );
      allMarkersList.add(allMarkers);

      return MarkerX(
        point: LatLng(latitude, longitude),
        onDraw: (canvas, offset) {
          canvas.drawCircle(offset + const Offset(0, height), 2, paint);
          textPainter.layout();
          textPainter.paint(
              canvas,
              offset +
                  Offset(-textPainter.width / 2,
                      -textPainter.height - height - 2));
        },
        width: markerWidth,
        height: markerHeight,
        identifier: identifier,
        countryCode: countryCode,
      );
    }).toList();

    wayPointsMarkers = wayPointRouteM;
    notifyListeners();
  }

  Future<void> loadFIRPolyline() async {
    List<LatLng> polyline = [];
    // Read the coordinates from the JSON file
    String jsonContent = await rootBundle.loadString('assets/FIR_UIR.json');
    List<dynamic> coordinates = json.decode(jsonContent);
    // Create a LatLng object for each coordinate pair
    for (var coordinate in coordinates) {
      double latitude = double.parse(coordinate['latitude'].toString());
      double longitude = double.parse(coordinate['longitude'].toString());
      LatLng latLng = LatLng(latitude, longitude);
      // print(longitude);
      polyline.add(latLng);
    }
    firPolyline = polyline;
    notifyListeners();
  }

  //List<List<LatLng> >airwayPolyLine = [];
  Future<void> loadWayAirwayLinesMarkers() async {
    double markerWidth = 40;
    double markerHeight = 40;
    // Load the JSON file containing the markers
    final String jsonString =
        await rootBundle.loadString('assets/airway_waypoints.json');
    // Decode the JSON data into a List of Maps
    //final List<dynamic> jsonData = await json.decode(jsonString);
    // Create a List of Markers from the JSON data
    final jsonResult = json.decode(jsonString);
    jsonResult.forEach((key, value) {
      final List<LatLng> polylinePoints = [];
      for (var i = 0; i < value.length; i++) {
        final LatLng point =
            LatLng(value[i]['latitude'], value[i]['longitude']);
        polylinePoints.add(point);
      }
      airwayPolyLine.add(polylinePoints);
      //notifyListeners();
    });
    notifyListeners();
  }

  Future<void> loadNavAidMarkers() async {
    double markerWidth = 5;
    double markerHeight = 5;
    const width = 3.0, height = 3.0;
    final paint = Paint()
      ..color = const Color.fromARGB(255, 6, 212, 244)
      ..strokeWidth = 2;
    const textStyle = TextStyle(
      fontSize: 10,
      //fontFamily: 'GLOUCEST',
      backgroundColor: Color.fromARGB(115, 34, 32,
          32), // Add this line to set the background color to white
      letterSpacing: 1,
    );
    final String jsonString = await rootBundle.loadString('assets/navAid.json');
    // Decode the JSON data into a List of Maps
    final List<dynamic> jsonData = await json.decode(jsonString);
    // Create a List of Markers from the JSON data
    List<MarkerX> navAidMarker = jsonData.map((data) {
      final double latitude = data['latitude'];
      final double longitude = data['longitude'];
      final String identifier = data['identifier'];
      final String frequency = data['frequency'];
      final String name = data["name"] +
          " " +
          identifier +
          " " +
          frequency +
          " " +
          data["frequency"];
      final String info = data['identifier'] + " " + data['frequency'];
      final textSpan = TextSpan(
        text: data['identifier'],
        style: textStyle,
      );
      final textPainter =
          TextPainter(text: textSpan, textDirection: TextDirection.ltr)
            ..textScaleFactor = 1.0;
      AllMarkers allMarkers = AllMarkers(
        code: data["identifier"],
        name: name,
        latitude: latitude,
        longitude: longitude,
      );
      allMarkersList.add(allMarkers);
      return MarkerX(
        frequency: frequency,
        anchorPos: AnchorPos.align(AnchorAlign.bottom),
        width: markerWidth,
        height: markerHeight,
        point: LatLng(latitude, longitude),
        identifier: identifier,
        onDraw: (canvas, offset) {
          canvas.drawCircle(offset + const Offset(0, height), 5, paint);
          textPainter.layout();
          textPainter.paint(
              canvas,
              offset +
                  Offset(-textPainter.width / 2,
                      -textPainter.height - height - 2));
        },
      );
    }).toList();
    // Set the airportMarkers list and return it
    navAidMarkers = navAidMarker;
    notifyListeners();
  }

  Future<void> loadWayFixPointMarkers() async {
    double markerWidth = 5;
    double markerHeight = 5;
    const width = 3.0, height = 3.0;
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;
    const textStyle = TextStyle(
      fontSize: 10,
      //fontFamily: 'GLOUCEST',
      backgroundColor: Color.fromARGB(115, 34, 32,
          32), // Add this line to set the background color to white
      letterSpacing: 1,
    );
    final String jsonString =
        await rootBundle.loadString('assets/way_point_fix.json');
    // Decode the JSON data into a List of Maps
    final List<dynamic> jsonData = await json.decode(jsonString);
    // Create a List of Markers from the JSON data
    List<MarkerX> wayPointRouteM = jsonData.map((data) {
      final String identifier = data["identifier"];
      // print(identifier);
      final double latitude = data['latitude'];
      final double longitude = data['longitude'];
      // final String airwayCode = data['airway_code'];
      //print(airwayCode);
      final textSpan = TextSpan(
        text: identifier,
        style: textStyle,
      );
      final textPainter =
          TextPainter(text: textSpan, textDirection: TextDirection.ltr)
            ..textScaleFactor = 1.0;
      AllMarkers allMarkers = AllMarkers(
        code: identifier,
        // name: airwayCode,
        latitude: latitude,
        longitude: longitude,
      );
      allMarkersList.add(allMarkers);
      return MarkerX(
        //  airwayCode: airwayCode,
        anchorPos: AnchorPos.align(AnchorAlign.bottom),
        width: markerWidth,
        height: markerHeight,
        point: LatLng(latitude, longitude),
        identifier: identifier,
        onDraw: (Canvas canvas, Offset offset) {
          canvas.drawCircle(offset + const Offset(0, height), 2, paint);
          textPainter.layout();
          textPainter.paint(
              canvas,
              offset +
                  Offset(-textPainter.width / 2,
                      -textPainter.height - height - 2));
        },
      );
    }).toList();
    // Set the airportMarkers list and return it
    reportingFixMarkers = wayPointRouteM;
    notifyListeners();
  }

//the last updated navigraph data
  Future<void> loadWayReportingPointMarkers() async {
    double markerWidth = 5;
    double markerHeight = 5;
    const width = 3.0, height = 3.0;
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;
    const textStyle = TextStyle(
      fontSize: 10,
      color: Colors.white,
      //fontFamily: 'GLOUCEST',
      backgroundColor: Color.fromARGB(115, 34, 32,
          32), // Add this line to set the background color to white
      letterSpacing: 1,
    );
    final String jsonString =
        await rootBundle.loadString('assets/waypoint_route.json');
    // Decode the JSON data into a List of Maps
    final List<dynamic> jsonData = await json.decode(jsonString);
    // Create a List of Markers from the JSON data
    List<MarkerX> wayPointRouteM = jsonData.map((data) {
      final String identifier = data["identifier"];
      // print(identifier);
      final double latitude = data['latitude'];
      final double longitude = data['longitude'];
      final String airwayCode = data['airway_code'];
      //print(airwayCode);
      final textSpan = TextSpan(
        text: identifier,
        style: textStyle,
      );
      final textPainter =
          TextPainter(text: textSpan, textDirection: TextDirection.ltr)
            ..textScaleFactor = 1.0;
      AllMarkers allMarkers = AllMarkers(
        code: identifier,
        name: airwayCode,
        latitude: latitude,
        longitude: longitude,
      );
      allMarkersList.add(allMarkers);
      return MarkerX(
        airwayCode: airwayCode,
        anchorPos: AnchorPos.align(AnchorAlign.bottom),
        width: markerWidth,
        height: markerHeight,
        point: LatLng(latitude, longitude),
        identifier: identifier,
        onDraw: (Canvas canvas, Offset offset) {
          canvas.drawCircle(offset + const Offset(0, height), 2, paint);
          textPainter.layout();
          textPainter.paint(
              canvas,
              offset +
                  Offset(-textPainter.width / 2,
                      -textPainter.height - height - 2));
        },
      );
    }).toList();
    // Set the airportMarkers list and return it
    reportingPointsMarkers = wayPointRouteM;
    notifyListeners();
  }

  Future<void> loadAirportMarkers() async {
    double markerWidth = 5;
    double markerHeight = 5;
    const width = 3.0, height = 3.0;
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 5;
    const textStyle = TextStyle(
      fontSize: 10,
      //fontFamily: 'GLOUCEST',
      color: Colors.white,
      backgroundColor: Color.fromARGB(115, 34, 32,
          32), // Add this line to set the background color to white
      letterSpacing: 1,
    );
    // Load the JSON file containing the markers
    final String jsonString =
        await rootBundle.loadString('assets/airport_markers.json');
    // Decode the JSON data into a List of Maps
    final List<dynamic> jsonData = await json.decode(jsonString);
    // Create a List of Markers from the JSON data
    List<MarkerX> apMarker = jsonData.map((data) {
      final double latitude = data['Airport Location']['Latitude'];
      final double longitude = data['Airport Location']['Longitude'];
      final String identifier = data['Airport Code'];
      final String name = data['Airport Name'];
      final double elevation = data['Airport Elevation'];
      allAirports.add(identifier);
      final List<int> altitudes = List<int>.from(data['Airport Altitudes']);
      List<Map<String, dynamic>> runwaysData =
          List<Map<String, dynamic>>.from(data['Runways']);
      List<Runway> runways = runwaysData.map((runway) {
        final String number = runway['Number'];
        final int inboundCourse = runway['Inbound Course'];
        final int length = runway['Length'];
        final int height = runway['Height'];
        final double runwayLatitude = runway['Location']['Latitude'];
        final double runwayLongitude = runway['Location']['Longitude'];
        final LatLng location = LatLng(runwayLatitude, runwayLongitude);
        return Runway(
          number: number,
          inboundCourse: inboundCourse,
          length: length,
          height: height,
          location: location,
        );
      }).toList();
      final Airport airport = Airport(
        code: identifier,
        name: name,
        location: LatLng(latitude, longitude),
        elevation: elevation,
        altitudes: altitudes,
        runways: runways,
      );
      final textSpan = TextSpan(
        text: identifier,
        style: textStyle,
      );
      final textPainter =
          TextPainter(text: textSpan, textDirection: TextDirection.ltr)
            ..textScaleFactor = 1.0;
      AllMarkers allMarkers = AllMarkers(
          code: identifier,
          name: name,
          latitude: latitude,
          longitude: longitude,
          elevation: elevation);
      allMarkersList.add(allMarkers);
      final String runwayInfo = runways
          .map((runway) =>
              '\nRunway: ${runway.number}\nInbound Course: ${runway.inboundCourse}\nLength: ${runway.length}\nHeight: ${runway.height}\nLocation: ${runway.location.latitude}, ${runway.location.longitude}')
          .join('\n');
      final String info =
          'Airport Code: $identifier \nAirport Name: $name\nElevation: $elevation\nAltitudes: $altitudes\n $runwayInfo';
      return MarkerX(
        name: name,
        anchorPos: AnchorPos.align(AnchorAlign.bottom),
        width: markerWidth,
        height: markerHeight,
        point: LatLng(latitude, longitude),
        identifier: identifier,
        onDraw: (canvas, offset) {
          canvas.drawCircle(offset + const Offset(0, height), 5, paint);
          textPainter.layout();
          textPainter.paint(
              canvas,
              offset +
                  Offset(-textPainter.width / 2,
                      -textPainter.height - height - 2));
        },
      );
    }).toList();
    // Set the airportMarkers list and return it
    //print(apMarker.length);
    airportMarkers = apMarker;
    notifyListeners();
  }

  // Future<void> loadAssets(BuildContext context) async {
  //   String jsonString = await DefaultAssetBundle.of(context)
  //       .loadString('assets/assetName.json');
  //   Map<String, dynamic> json = jsonDecode(jsonString);
  //   AssetFileList data = AssetFileList.fromJson(json);

  //   printAssetFileNames(data);
  // }

  // void printAssetFileNames(AssetFileList assetFile) {
  //   print(assetFile.name); // Print name of main folder

  //   for (var child in assetFile.children) {
  //     if (child.type == 'folder') {
  //       printFolderNames(
  //           child, 1); // Print names of subfolders and children recursively
  //     }
  //   }
  // }

  // void printFolderNames(FolderChild folder, int indentLevel) {
  //   print('${' ' * indentLevel}${folder.name}'); // Print name of folder

  //   if (folder.children != null) {
  //     for (var child in folder.children!) {
  //       if (child.type == 'folder') {
  //         printFolderNames(
  //             child,
  //             indentLevel +
  //                 1); // Print names of subfolders and children recursively
  //       } else {
  //         print(
  //             '${' ' * (indentLevel + 1)}${child.name}'); // Print name of child file
  //       }
  //     }
  //   }
  // }

  Future<void> loadBorder() async {
    // Load GeoJSON data from asset file
    String data = await rootBundle.loadString('assets/nepal.geojson');
    Map<String, dynamic> geoJson = await json.decode(data);
    List<dynamic> features = geoJson['features'];
    for (int i = 0; i < features.length; i++) {
      String geometryType = features[i]['geometry']['type'];
      List<dynamic> nestedCoords = features[i]['geometry']['coordinates'];
      List<List<LatLng>> bordersForFeature = [];
      if (geometryType == 'MultiPolygon') {
        for (int j = 0; j < nestedCoords.length; j++) {
          List<dynamic> coordinates = nestedCoords[j][0];
          List<LatLng> border = coordinates.map((coordinate) {
            double lat = coordinate[1];
            double lng = coordinate[0];
            if (lng > 180) lng = lng - 360;
            if (lng < -180) lng = lng + 360;
            if (lat > 90) lat = 90;
            if (lat < -90) lat = -90;
            return LatLng(lat, lng);
          }).toList();
          bordersForFeature.add(border);
        }
      } else if (geometryType == 'Polygon') {
        List<dynamic> coordinates = nestedCoords[0];
        List<LatLng> border = coordinates.map((coordinate) {
          double lat = coordinate[1];
          double lng = coordinate[0];
          if (lng > 180) lng = lng - 360;
          if (lng < -180) lng = lng + 360;
          if (lat > 90) lat = 90;
          if (lat < -90) lat = -90;
          return LatLng(lat, lng);
        }).toList();
        bordersForFeature.add(border);
      }
      borders.addAll(bordersForFeature);
      notifyListeners();
    }
  }
}

class Runway {
  final String number;
  final int inboundCourse;
  final int length;
  final int height;
  final LatLng location;
  Runway({
    required this.number,
    required this.inboundCourse,
    required this.length,
    required this.height,
    required this.location,
  });
}

class Airport {
  final String code;
  final String name;
  final LatLng location;
  final double elevation;
  final List<int> altitudes;
  final List<Runway> runways;
  Airport({
    required this.code,
    required this.name,
    required this.location,
    required this.elevation,
    required this.altitudes,
    required this.runways,
  });
}
