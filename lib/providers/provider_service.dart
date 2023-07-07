// ignore_for_file: non_constant_identifier_names
//import 'dart:ffi';
import 'package:flutter/material.dart';
//import 'package:flutter_map/flutter_map.dart';
import 'package:fly_nepal/modified_flutter_class/overLayImageX.dart';
import 'package:fly_nepal/modified_flutter_class/overLayImageY.dart';
//import 'package:fly_nepal/test_map_widgets/overLayImageY.dart';
import 'package:latlong2/latlong.dart';

dynamic chosenPlate; // = chartNameConfig; //VNKT_VOR_RWY_02;
dynamic VORD02 = "VORD02";
dynamic VORDZ09 = "VORDZ09";
dynamic editPlate = "";
Map<dynamic, LatLng> topL = {};
Map<dynamic, LatLng> botL = {};
Map<dynamic, LatLng> botR = {};
bool mapInteraction = true;

class ProviderService extends ChangeNotifier {
  double tolerance = 0.001;
  LatLng editPlateTL = const LatLng(0, 0);
  LatLng editPlateBL = const LatLng(0, 0);
  LatLng editPlateBR = const LatLng(0, 0);

  LatLng previousPlateTL = const LatLng(0, 0);
  LatLng previousPlateBL = const LatLng(0, 0);
  LatLng previousPlateBR = const LatLng(0, 0);
  bool mapInteraction = false;
  bool showMapResizeWidget = false;

  void setTolerance(double tol) {
    tolerance = tol;
    notifyListeners();
  }

  void showResizeWid(bool showWidget) {
    showMapResizeWidget = showWidget;
    notifyListeners();
  }

  void isMapInteractive(bool mapInteraction) {
    mapInteraction = mapInteraction;
    notifyListeners();
  }

  bool mapReady = false;
  void isMapReady(bool isReady) {
    mapReady = isReady;
    notifyListeners();
  }

  List<BaseOverlayImageX> overlayImagesX = [];
  void setOverlayImagesX(List<BaseOverlayImageX> images) {
    overlayImagesX = images;

    notifyListeners();
  }

  void clear() {
    overlayImagesX.clear();
    notifyListeners();
  }

  void initializeChartValues() {
    topL = {
      //  editPlate: editPlateTL,
      //VNKT
      VORD02: const LatLng(28.0665487, 84.7436897),
      //VNVT
      VORDZ09: const LatLng(27.0512681, 86.6531214)
    };
    botL = {
      //  editPlate: editPlateBL,
      //VNKT
      VORD02: LatLng(26.7569688, topL[VORD02]!.longitude),
      //VNVT
      VORDZ09: LatLng(25.8431636, topL[VORDZ09]!.longitude)
    };
    botR = {
      //editPlate: editPlateBR,
      //VNKT
      VORD02: LatLng(botL[VORD02]!.latitude, 85.83642979999999),
      //VNVT
      VORDZ09: LatLng(botL[VORDZ09]!.latitude, 87.6128335)
    };
  }

  Future<void> addTestRotatedOverLayImageX(
      dynamic chartName,
      dynamic folderName,
      LatLng topLeft,
      LatLng botLeft,
      LatLng botRight) async {
    //initializeChartValues(); // Initialize chart values before usage
    print('addtestProvider $chartName');
    dynamic chart = chartName.toString().replaceAll(RegExp(r'.png'), "");
    editPlate = chart;
    topL[editPlate] = topLeft;
    botL[editPlate] = botLeft;
    botR[editPlate] = botRight;
    final newImage = RotatedOverlayImageX(
      chartName: chart,
      topLeftCorner: topLeft,
      bottomLeftCorner: botLeft,
      bottomRightCorner: botRight,
      opacity: 1,
      imageProvider: AssetImage('assets/charts/$folderName'),
      // imageProvider: const AssetImage('assets/Jchart_crop.png'),
    );
    overlayImagesX.add(newImage);
    //initializeChartValues();
    notifyListeners();
    // }
  }

  Future<void> addRotatedOverLayImageX(
      String? chartPath, dynamic chartName) async {
    initializeChartValues(); // Initialize chart values before usageflut
    dynamic chart = chartName.toString().replaceAll(RegExp(r'.png'), "");
    final topLeft = topL[chart];
    final botLeft = botL[chart];
    final botRight = botR[chart];
    //print('topLeft $topLeft');
    if (topLeft != null && botLeft != null && botRight != null) {
      // print('in');
      final newImage = RotatedOverlayImageX(
        chartName: chart,
        topLeftCorner: topLeft,
        bottomLeftCorner: botLeft,
        bottomRightCorner: botRight,
        opacity: 1,
        imageProvider: AssetImage('assets/charts/$chartPath'),
      );
      overlayImagesX.add(newImage);
      notifyListeners();
    }
  }

  Future<void> clearChar() async {
    overlayImagesX.clear();
    initializeChartValues(); // Reset values for all charts
  }

  void updateOverlayImagesX(
      String chartName, LatLng topLeft, LatLng bottomLeft, LatLng bottomRight) {
    overlayImagesX = overlayImagesX.map((image) {
      previousPlateTL = topLeft;
      previousPlateBL = bottomLeft;
      previousPlateBR = bottomRight;

      return RotatedOverlayImageX(
        chartName: chartName,
        topLeftCorner: topLeft,
        bottomLeftCorner: bottomLeft,
        bottomRightCorner: bottomRight,
        opacity: image.opacity,
        imageProvider: image.imageProvider,
      );
    }).toList();
  }

  void setPreviousChatPosition() {
    topL[chosenPlate] = previousPlateTL;
    botL[chosenPlate] = previousPlateBL;
    botR[chosenPlate] = previousPlateBR;
    updateOverlayImagesX(chosenPlate, topL[chosenPlate]!, botL[chosenPlate]!,
        botR[chosenPlate]!);

    notifyListeners();
  }

  void moveLeft() {
    final currentLatLng = topL[chosenPlate]!;
    final updatedLongitude = currentLatLng.longitude - tolerance;
    final updatedLatLng = LatLng(currentLatLng.latitude, updatedLongitude);

    topL[chosenPlate] = updatedLatLng;
    botL[chosenPlate] = LatLng(
        botL[chosenPlate]!.latitude, botL[chosenPlate]!.longitude - tolerance);
    botR[chosenPlate] = LatLng(
        botR[chosenPlate]!.latitude, botR[chosenPlate]!.longitude - tolerance);

    updateOverlayImagesX(
        chosenPlate, updatedLatLng, botL[chosenPlate]!, botR[chosenPlate]!);

    notifyListeners();
  }

  void moveDown() {
    final currentLatLng = topL[chosenPlate]!;
    final updatedLatLng =
        LatLng(currentLatLng.latitude - tolerance, currentLatLng.longitude);

    topL[chosenPlate] = updatedLatLng;
    botL[chosenPlate] = LatLng(
        botL[chosenPlate]!.latitude - tolerance, botL[chosenPlate]!.longitude);
    botR[chosenPlate] = LatLng(
        botR[chosenPlate]!.latitude - tolerance, botR[chosenPlate]!.longitude);

    updateOverlayImagesX(chosenPlate, topL[chosenPlate]!, botL[chosenPlate]!,
        botR[chosenPlate]!);

    notifyListeners();
  }

  void moveUp() {
    final currentLatLng = topL[chosenPlate]!;
    final updatedLatLng =
        LatLng(currentLatLng.latitude + tolerance, currentLatLng.longitude);

    topL[chosenPlate] = updatedLatLng;
    botL[chosenPlate] = LatLng(
        botL[chosenPlate]!.latitude + tolerance, botL[chosenPlate]!.longitude);
    botR[chosenPlate] = LatLng(
        botR[chosenPlate]!.latitude + tolerance, botR[chosenPlate]!.longitude);

    updateOverlayImagesX(chosenPlate, topL[chosenPlate]!, botL[chosenPlate]!,
        botR[chosenPlate]!);

    notifyListeners();
  }

  void moveRight() {
    final currentLatLng = topL[chosenPlate]!;
    final updatedLatLng =
        LatLng(currentLatLng.latitude, currentLatLng.longitude + tolerance);

    topL[chosenPlate] = updatedLatLng;
    botL[chosenPlate] = LatLng(
        botL[chosenPlate]!.latitude, botL[chosenPlate]!.longitude + tolerance);
    botR[chosenPlate] = LatLng(
        botR[chosenPlate]!.latitude, botR[chosenPlate]!.longitude + tolerance);

    updateOverlayImagesX(chosenPlate, topL[chosenPlate]!, botL[chosenPlate]!,
        botR[chosenPlate]!);

    notifyListeners();
  }

  void zoomIn() {
    final currentLatLng = topL[chosenPlate]!;
    final updatedTopLLatLng = LatLng(currentLatLng.latitude + tolerance,
        currentLatLng.longitude - tolerance);
    final updatedBotLLatLng = LatLng(botL[chosenPlate]!.latitude - tolerance,
        botL[chosenPlate]!.longitude - tolerance);
    final updatedBotRLatLng = LatLng(botR[chosenPlate]!.latitude - tolerance,
        botR[chosenPlate]!.longitude + tolerance);

    topL[chosenPlate] = updatedTopLLatLng;
    botL[chosenPlate] = updatedBotLLatLng;
    botR[chosenPlate] = updatedBotRLatLng;

    updateOverlayImagesX(
        chosenPlate, updatedTopLLatLng, updatedBotLLatLng, updatedBotRLatLng);

    notifyListeners();
  }

  void zoomOut() {
    final currentLatLng = topL[chosenPlate]!;
    final updatedTopLLatLng = LatLng(currentLatLng.latitude - tolerance,
        currentLatLng.longitude + tolerance);
    final updatedBotLLatLng = LatLng(botL[chosenPlate]!.latitude + tolerance,
        botL[chosenPlate]!.longitude + tolerance);
    final updatedBotRLatLng = LatLng(botR[chosenPlate]!.latitude + tolerance,
        botR[chosenPlate]!.longitude - tolerance);

    topL[chosenPlate] = updatedTopLLatLng;
    botL[chosenPlate] = updatedBotLLatLng;
    botR[chosenPlate] = updatedBotRLatLng;

    updateOverlayImagesX(
        chosenPlate, updatedTopLLatLng, updatedBotLLatLng, updatedBotRLatLng);

    notifyListeners();
  }

  void dragLeft() {
    final currentLatLng = topL[chosenPlate]!;
    final updatedLatLng =
        LatLng(currentLatLng.latitude, currentLatLng.longitude - tolerance);

    topL[chosenPlate] = updatedLatLng;
    botL[chosenPlate] = LatLng(
        botL[chosenPlate]!.latitude, botL[chosenPlate]!.longitude - tolerance);

    updateOverlayImagesX(
        chosenPlate, updatedLatLng, botL[chosenPlate]!, botR[chosenPlate]!);

    notifyListeners();
  }

  void dragLeftback() {
    final currentLatLng = topL[chosenPlate]!;
    final updatedLatLng =
        LatLng(currentLatLng.latitude, currentLatLng.longitude + tolerance);

    topL[chosenPlate] = updatedLatLng;
    botL[chosenPlate] = LatLng(
        botL[chosenPlate]!.latitude, botL[chosenPlate]!.longitude + tolerance);

    updateOverlayImagesX(
        chosenPlate, updatedLatLng, botL[chosenPlate]!, botR[chosenPlate]!);

    notifyListeners();
  }

  void dragDown() {
    final updatedBotLLatLng = LatLng(
        botL[chosenPlate]!.latitude - tolerance, botL[chosenPlate]!.longitude);
    final updatedBotRLatLng = LatLng(
        botR[chosenPlate]!.latitude - tolerance, botR[chosenPlate]!.longitude);

    botL[chosenPlate] = updatedBotLLatLng;
    botR[chosenPlate] = updatedBotRLatLng;

    updateOverlayImagesX(
        chosenPlate, topL[chosenPlate]!, updatedBotLLatLng, updatedBotRLatLng);

    notifyListeners();
  }

  void dragDownBack() {
    final updatedBotLLatLng = LatLng(
        botL[chosenPlate]!.latitude + tolerance, botL[chosenPlate]!.longitude);
    final updatedBotRLatLng = LatLng(
        botR[chosenPlate]!.latitude + tolerance, botR[chosenPlate]!.longitude);

    botL[chosenPlate] = updatedBotLLatLng;
    botR[chosenPlate] = updatedBotRLatLng;

    updateOverlayImagesX(
        chosenPlate, topL[chosenPlate]!, updatedBotLLatLng, updatedBotRLatLng);

    notifyListeners();
  }

  void dragUp() {
    final updatedTopLLatLng = LatLng(
        topL[chosenPlate]!.latitude + tolerance, topL[chosenPlate]!.longitude);

    topL[chosenPlate] = updatedTopLLatLng;

    updateOverlayImagesX(
        chosenPlate, updatedTopLLatLng, botL[chosenPlate]!, botR[chosenPlate]!);

    notifyListeners();
  }

  void dragUpBack() {
    final updatedTopLLatLng = LatLng(
        topL[chosenPlate]!.latitude - tolerance, topL[chosenPlate]!.longitude);

    topL[chosenPlate] = updatedTopLLatLng;

    updateOverlayImagesX(
        chosenPlate, updatedTopLLatLng, botL[chosenPlate]!, botR[chosenPlate]!);

    notifyListeners();
  }

  void dragRight() {
    final updatedBotRLatLng = LatLng(
        botR[chosenPlate]!.latitude, botR[chosenPlate]!.longitude + tolerance);

    botR[chosenPlate] = updatedBotRLatLng;

    updateOverlayImagesX(
        chosenPlate, topL[chosenPlate]!, botL[chosenPlate]!, updatedBotRLatLng);

    notifyListeners();
  }

  void dragRightBack() {
    final updatedBotRLatLng = LatLng(
        botR[chosenPlate]!.latitude, botR[chosenPlate]!.longitude - tolerance);

    botR[chosenPlate] = updatedBotRLatLng;

    updateOverlayImagesX(
        chosenPlate, topL[chosenPlate]!, botL[chosenPlate]!, updatedBotRLatLng);

    notifyListeners();
  }

  void moveTopLeft() {
    moveUp();
    moveLeft();
    notifyListeners();
  }

  void moveTopRight() {
    moveUp();
    moveRight();
    notifyListeners();
  }

  void moveBottomRight() {
    moveDown();
    moveRight();
    notifyListeners();
  }

  void moveBottomLeft() {
    moveDown();
    moveLeft();
    notifyListeners();
  }
}
