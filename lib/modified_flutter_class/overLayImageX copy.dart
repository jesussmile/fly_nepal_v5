import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:fly_nepal/providers/provider_service.dart';

import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

dynamic selectedChart = "";

abstract class BaseOverlayImageX {
  ImageProvider get imageProvider;
  bool selected = false;
  double get opacity;
  bool get gaplessPlayback;
  buildPositionedForOverlay(FlutterMapState map, BuildContext context);

  buildImageForOverlay(dynamic chartName, BuildContext context) {
    final provider = Provider.of<ProviderService>(context, listen: false);

    return GestureDetector(
      onDoubleTap: () {
        // print("inside overlay");
        mapInteraction = !mapInteraction;
        selectedChart = chartName;
        chosenPlate = chartName;
        provider.showResizeWid(!provider.showMapResizeWidget);
      },
      child: Container(
        color: !mapInteraction && selectedChart == chartName
            ? const Color.fromARGB(255, 167, 247, 169)
            : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image(
            image: imageProvider,
            fit: BoxFit.fill,
            color: Color.fromRGBO(255, 255, 255, opacity),
            colorBlendMode: BlendMode.modulate,
            gaplessPlayback: gaplessPlayback,
          ),
        ),
      ),
    );
  }
}

class RotatedOverlayImageX extends BaseOverlayImageX {
  @override
  final ImageProvider imageProvider;
  final dynamic chartName;
  final LatLng topLeftCorner, bottomLeftCorner, bottomRightCorner;
  @override
  final double opacity;
  @override
  final bool gaplessPlayback;
  final FilterQuality? filterQuality;
  RotatedOverlayImageX(
      {required this.imageProvider,
      required this.topLeftCorner,
      required this.bottomLeftCorner,
      required this.bottomRightCorner,
      required this.chartName,
      this.opacity = 1.0,
      this.gaplessPlayback = false,
      this.filterQuality = FilterQuality.medium});
  @override
  Positioned buildPositionedForOverlay(
      FlutterMapState map, BuildContext context) {
    final pxTopLeft = map.project(topLeftCorner) - map.pixelOrigin;
    final pxBottomRight = map.project(bottomRightCorner) - map.pixelOrigin;
    final pxBottomLeft = map.project(bottomLeftCorner) - map.pixelOrigin;
    final pxTopRight = (pxTopLeft - pxBottomLeft + pxBottomRight);
    final bounds = Bounds<num>(pxTopLeft, pxBottomRight)
        .extend(pxTopRight)
        .extend(pxBottomLeft);
    final vectorX = (pxTopRight - pxTopLeft) / bounds.size.x;
    final vectorY = (pxBottomLeft - pxTopLeft) / bounds.size.y;
    final offset = pxTopLeft - bounds.topLeft;
    final a = vectorX.x.toDouble();
    final b = vectorX.y.toDouble();
    final c = vectorY.x.toDouble();
    final d = vectorY.y.toDouble();
    final tx = offset.x.toDouble();
    final ty = offset.y.toDouble();
    return Positioned(
        left: bounds.topLeft.x.toDouble(),
        top: bounds.topLeft.y.toDouble(),
        width: bounds.size.x.toDouble(),
        height: bounds.size.y.toDouble(),
        child: Transform(
            transform:
                Matrix4(a, b, 0, 0, c, d, 0, 0, 0, 0, 1, 0, tx, ty, 0, 1),
            filterQuality: filterQuality,
            child: buildImageForOverlay(chartName, context)));
  }
}

class OverlayImageLayerX extends StatelessWidget {
  final List<BaseOverlayImageX> overlayImages;
  const OverlayImageLayerX({super.key, this.overlayImages = const []});
  @override
  Widget build(BuildContext context) {
    final map = FlutterMapState.maybeOf(context)!;
    return ClipRect(
      child: Stack(
        children: <Widget>[
          for (var overlayImage in overlayImages)
            overlayImage.buildPositionedForOverlay(map, context),
        ],
      ),
    );
  }
}
