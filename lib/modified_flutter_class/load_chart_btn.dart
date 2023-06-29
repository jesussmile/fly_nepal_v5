import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:fly_nepal/providers/provider_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class FlutterMapZoomButtonsX extends StatelessWidget {
  final double minZoom;
  final double maxZoom;
  final bool mini;
  final double padding;
  final Alignment alignment;
  final Color? zoomInColor;
  final Color? zoomInColorIcon;
  final Color? zoomOutColor;
  final Color? zoomOutColorIcon;
  final IconData zoomInIcon;
  final IconData zoomOutIcon;

  final FitBoundsOptions options =
      const FitBoundsOptions(padding: EdgeInsets.all(12));

  const FlutterMapZoomButtonsX({
    super.key,
    this.minZoom = 1,
    this.maxZoom = 18,
    this.mini = true,
    this.padding = 2.0,
    this.alignment = Alignment.topRight,
    this.zoomInColor,
    this.zoomInColorIcon,
    this.zoomInIcon = Icons.add,
    this.zoomOutColor,
    this.zoomOutColorIcon,
    this.zoomOutIcon = Icons.zoom_out,
  });

  @override
  Widget build(BuildContext context) {
    final map = FlutterMapState.maybeOf(context)!;
    return Align(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(left: padding, top: padding, right: padding),
            child: FloatingActionButton(
              heroTag: 'zoomInButton',
              mini: mini,
              backgroundColor: zoomInColor ?? Theme.of(context).primaryColor,
              onPressed: () {
                getImageSize('Jchart_crop.png', context);
              },
              child: Icon(zoomInIcon,
                  color: zoomInColorIcon ?? IconTheme.of(context).color),
            ),
          ),
        ],
      ),
    );
  }

  void getImageSize(String chartName, BuildContext context) {
    final map = FlutterMapState.maybeOf(context)!;
    final imageProvider = AssetImage('assets/$chartName');
    final imageStream = imageProvider.resolve(const ImageConfiguration());
    int width = 0;
    int height = 0;
    imageStream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      width = info.image.width;
      height = info.image.height;
      print('Overlay image width: $width, height: $height');
      calculateImageCorners(map.center, width, height, map.zoom + 3.14159265,
          chartName, context, map);
    }));
  }

  //void calculateImageCorners() {
  void calculateImageCorners(
      LatLng center,
      int imageWidth,
      int imageHeight,
      double mapZoom,
      dynamic chartName,
      BuildContext context,
      FlutterMapState map) {
    print(map.pixelOrigin);
    // map.latLngToScreenPoint(LatLng(26.99063916405502, 85.39807463364063));
    //map.project(LatLng(26.99063916405502, 85.39807463364063));
    print('${map.project(map.center)}');
    // print(flutterMapController.center);
    // final map = FlutterMapState.maybeOf(context);

    final scaleFactor = 1 / (2 * pow(2, mapZoom));
    // print('Zoom Level: $zoomLevel');
    // Calculate half width and half height in latitude and longitude
    final halfWidth = imageWidth * scaleFactor / 2;
    final halfHeight = imageHeight * scaleFactor / 2;
    // Calculate top left corner coordinates
    final topLeftLatitude = center.latitude + halfHeight;
    final topLeftLongitude = center.longitude - halfWidth;
    // Calculate bottom left corner coordinates
    final bottomLeftLatitude = center.latitude - halfHeight;
    final bottomLeftLongitude = center.longitude - halfWidth;
    // Calculate bottom right corner coordinates
    final bottomRightLatitude = center.latitude - halfHeight;
    final bottomRightLongitude = center.longitude + halfWidth;
    // Print the results
    print(chartName);
    LatLng topC = LatLng(topLeftLatitude, topLeftLongitude);
    LatLng botC = LatLng(bottomLeftLatitude, topLeftLongitude);
    LatLng rightC = LatLng(bottomLeftLatitude, bottomRightLongitude);

    // LatLng topC = LatLng(28.57621676093576, 81.37445798493886);
    // LatLng botC = LatLng(27.855899901011938, 81.37445798493886);
    // LatLng rightC = LatLng(27.855899901011938, 81.90016133822238);
    Provider.of<ProviderService>(context, listen: false)
        .addTestRotatedOverLayImageX(chartName, "", topC, botC, rightC);
    print('Top Left: $topLeftLatitude, $topLeftLongitude');
    print('Bottom Left: $bottomLeftLatitude, $bottomLeftLongitude');
    print('Bottom Right: $bottomRightLatitude, $bottomRightLongitude');
  }
}
