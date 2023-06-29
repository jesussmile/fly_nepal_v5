import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fly_nepal/colors/custom_colors.dart';
import 'package:fly_nepal/model/all_markers.dart';
import 'package:fly_nepal/model/chip_modal.dart';
import 'package:fly_nepal/providers/MarkerListProvider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class ChipManager {
  static void addChip(BuildContext context,
      TextEditingController chipTextController, String type) {
    var provider = Provider.of<MarkerListProvider>(context, listen: false);
    List<AllMarkers> matchingMarkerList = [];
    String? matchCode;
    bool customUserPoint = false;
    List<String> splitwayP = [];
    String wayP = "";
    double radial = 0;
    double dme = 0;
    if (chipTextController.text.trim().isNotEmpty) {
      matchCode = chipTextController.text.trim().toUpperCase().toString();
      //check if KTM/105/20
      if (matchCode.contains("/")) {
        customUserPoint = true;
        splitwayP = matchCode.split('/');
        matchCode = splitwayP[0];
        radial = double.parse(splitwayP[1]);
        dme = double.parse(splitwayP[2]);
      }
      List<AllMarkers> allMarkersList = provider.allMarkersList;
      for (AllMarkers markers in allMarkersList) {
        //check if KTM/105/20
        if (markers.code == matchCode) {
          if (!matchingMarkerList
              .any((element) => element.latitude == markers.latitude)) {
            matchingMarkerList.add(markers);
          }
        }
      }
      //multiple points with same name with different Lat lng
      if (matchingMarkerList.isNotEmpty && matchingMarkerList.length > 1) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: CustomColor.darkBlue.color,
                title: const Text(
                  "Multiple WayPoints",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                content: SizedBox(
                  width: 300,
                  height: matchingMarkerList.length * 70,
                  child: ListView.builder(
                    //reverse: true,
                    itemCount: matchingMarkerList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        shape: const Border(
                            bottom: BorderSide(color: Colors.white)),
                        onTap: () {
                          customUserPoint
                              ? convertRadialDMEToCoordinates(
                                  //KTM/105/25
                                  LatLng(matchingMarkerList[index].latitude,
                                      matchingMarkerList[index].longitude),
                                  radial,
                                  dme,
                                  context,
                                  matchingMarkerList,
                                  index,
                                  type)
                              : fixedWayPoints(
                                  context, matchingMarkerList, index, type);

                          chipTextController.clear();
                          Navigator.pop(context);
                        },
                        title: Text(
                          "${matchingMarkerList[index].code}\nLatitude: ${matchingMarkerList[index].latitude}\nLongitude: ${matchingMarkerList[index].longitude}",
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            });
      } else if (matchingMarkerList.length == 1) {
        customUserPoint
            ? convertRadialDMEToCoordinates(
                LatLng(matchingMarkerList[0].latitude,
                    matchingMarkerList[0].longitude),
                radial,
                dme,
                context,
                matchingMarkerList,
                0,
                type)
            : fixedWayPoints(context, matchingMarkerList, 0, type);

        // provider.chipList.add(ChipModel(
        //     id: DateTime.now().toString(),
        //     name: matchingMarkerList[0].code,
        //     latLng: LatLng(matchingMarkerList[0].latitude,
        //         matchingMarkerList[0].longitude),
        //     type: type));
        chipTextController.clear();
        // provider.userLatL(LatLng(
        //     matchingMarkerList[0].latitude, matchingMarkerList[0].longitude));
        // Provider.of<MarkerListProvider>(context, listen: false)
        //     .loadCustomMarker(matchingMarkerList[0].latitude,
        //         matchingMarkerList[0].longitude, matchingMarkerList[0].code);

        //VOR DME
      } else if (matchingMarkerList.isEmpty) {
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: CustomColor.darkBlue.color,
            title: const Text(
              "Not a valid Way Point",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    }
  }

  static void deleteChip(BuildContext context, String name, String type,
      {LatLng? latLng, List<LatLng>? listLatlng}) {
    var provider = Provider.of<MarkerListProvider>(context, listen: false);
    // print(name);
    provider.chipList.removeWhere((element) => element.name == name);
    if (type == 'sid') {
      provider.removeSidL();
      // provider.removeSidFixTrans();
    } else if (type == 'star') {
      provider.removeStar();
    } else if (type == "approach") {
      provider.removeApproach();
    } else if (type == 'user') {
      provider.totalUserLatLng.removeWhere((list) => list.contains(latLng));
      provider.removeCustomMarker(name);
    }
  }

  static onReorder(BuildContext context, int oldIndex, int newIndex) {
    var provider = Provider.of<MarkerListProvider>(context, listen: false);
    ChipModel row = provider.chipList.removeAt(oldIndex);
    provider.chipList.insert(newIndex, row);
    List<LatLng> listLatLng = provider.totalUserLatLng.removeAt(oldIndex);
    provider.totalUserLatLng.insert(newIndex, listLatLng);
  }

  static double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  static double radiansToDegrees(double radians) {
    return radians * 180.0 / pi;
  }

  static void convertRadialDMEToCoordinates(
    LatLng wayPoint,
    double radial,
    double dme,
    BuildContext context,
    List<AllMarkers> matchingMarkerList,
    int index,
    String type,
  ) {
    double distanceInNM = dme;
    double radialInRadians = degreesToRadians(radial);
    double lat1 = degreesToRadians(wayPoint.latitude);
    double lon1 = degreesToRadians(wayPoint.longitude);
    double earthRadiusNM = 3440.07; // Earth's radius in nautical miles
    double lat2 = asin(sin(lat1) * cos(distanceInNM / earthRadiusNM) +
        cos(lat1) * sin(distanceInNM / earthRadiusNM) * cos(radialInRadians));
    double lon2 = lon1 +
        atan2(
            sin(radialInRadians) *
                sin(distanceInNM / earthRadiusNM) *
                cos(lat1),
            cos(distanceInNM / earthRadiusNM) - sin(lat1) * sin(lat2));
    LatLng coordinates = LatLng(
      radiansToDegrees(lat2),
      radiansToDegrees(lon2),
    );
    dynamic provider = Provider.of<MarkerListProvider>(context, listen: false);
    provider.chipList.add(
      ChipModel(
        id: DateTime.now().toString(),
        name:
            '${matchingMarkerList[index].code}/${radial.truncate()}/${dme.truncate()}',
        latLng: coordinates,
        type: type,
      ),
    );
    provider.userLatL(coordinates);
    Provider.of<MarkerListProvider>(context, listen: false).loadCustomMarker(
      coordinates.latitude,
      coordinates.longitude,
      '${matchingMarkerList[index].code}/${radial.truncate()}/${dme.truncate()}',
    );
  }

  static void fixedWayPoints(BuildContext context,
      List<AllMarkers> matchingMarkerList, int index, String type) {
    dynamic provider = Provider.of<MarkerListProvider>(context, listen: false);
    provider.chipList.add(ChipModel(
        id: DateTime.now().toString(),
        name: matchingMarkerList[index].code,
        latLng: LatLng(matchingMarkerList[index].latitude,
            matchingMarkerList[index].longitude),
        type: type));
    provider.userLatL(LatLng(matchingMarkerList[index].latitude,
        matchingMarkerList[index].longitude));
    Provider.of<MarkerListProvider>(context, listen: false).loadCustomMarker(
        matchingMarkerList[index].latitude,
        matchingMarkerList[index].longitude,
        matchingMarkerList[index].code);
  }
}
