import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
// import 'package:flutter_map/src/core/bounds.dart';
// import 'package:flutter_map/src/map/flutter_map_state.dart';
import 'package:latlong2/latlong.dart';

class Anchor {
  final double left;
  final double top;
  Anchor(this.left, this.top);
  Anchor._(double width, double height, AnchorAlign alignOpt)
      : left = _leftOffset(width, alignOpt),
        top = _topOffset(height, alignOpt);
  static double _leftOffset(double width, AnchorAlign alignOpt) {
    switch (alignOpt) {
      case AnchorAlign.left:
        return 0;
      case AnchorAlign.right:
        return width;
      case AnchorAlign.top:
      case AnchorAlign.bottom:
      case AnchorAlign.center:
      default:
        return width / 2;
    }
  }

  static double _topOffset(double height, AnchorAlign alignOpt) {
    switch (alignOpt) {
      case AnchorAlign.top:
        return 0;
      case AnchorAlign.bottom:
        return height;
      case AnchorAlign.left:
      case AnchorAlign.right:
      case AnchorAlign.center:
      default:
        return height / 2;
    }
  }

  factory Anchor.forPos(AnchorPos<dynamic>? pos, double width, double height) {
    if (pos == null) return Anchor._(width, height, AnchorAlign.none);
    if (pos.value is AnchorAlign) {
      return Anchor._(width, height, pos.value as AnchorAlign);
    }
    if (pos.value is Anchor) return pos.value as Anchor;
    throw Exception('Unsupported AnchorPos value type: ${pos.runtimeType}.');
  }
}

class AnchorPos<T> {
  AnchorPos._(this.value);
  T value;
  static AnchorPos<Anchor> exactly(Anchor anchor) =>
      AnchorPos<Anchor>._(anchor);
  static AnchorPos<AnchorAlign> align(AnchorAlign alignOpt) =>
      AnchorPos<AnchorAlign>._(alignOpt);
}

enum AnchorAlign {
  none,
  left,
  right,
  top,
  bottom,
  center,
}

class Marker {
  final LatLng point;
  final WidgetBuilder builder;
  final Key? key;
  final double width;
  final double height;
  final Anchor anchor;
  final bool? rotate;
  final Offset? rotateOrigin;
  final AlignmentGeometry? rotateAlignment;
  Marker({
    required this.point,
    required this.builder,
    this.key,
    this.width = 30.0,
    this.height = 30.0,
    this.rotate,
    this.rotateOrigin,
    this.rotateAlignment,
    AnchorPos<dynamic>? anchorPos,
  }) : anchor = Anchor.forPos(anchorPos, width, height);
}

class MarkerLayer extends StatelessWidget {
  final List<Marker> markers;
  final bool rotate;
  final Offset? rotateOrigin;
  final AlignmentGeometry? rotateAlignment;
  const MarkerLayer(
      {super.key,
      this.markers = const [],
      this.rotate = false,
      this.rotateOrigin,
      this.rotateAlignment = Alignment.center});
  @override
  Widget build(BuildContext context) {
    final map = FlutterMapState.maybeOf(context)!;
    final markerWidgets = <Widget>[];
    for (final marker in markers) {
      final pxPoint = map.project(marker.point);
      final rightPortion = marker.width - marker.anchor.left;
      final leftPortion = marker.anchor.left;
      final bottomPortion = marker.height - marker.anchor.top;
      final topPortion = marker.anchor.top;
      final sw =
          CustomPoint(pxPoint.x + leftPortion, pxPoint.y - bottomPortion);
      final ne = CustomPoint(pxPoint.x - rightPortion, pxPoint.y + topPortion);
      if (!map.pixelBounds.containsPartialBounds(Bounds(sw, ne))) {
        continue;
      }
      final pos = pxPoint - map.pixelOrigin;
      final markerWidget = (marker.rotate ?? rotate)
          ? Transform.rotate(
              angle: -map.rotationRad,
              origin: marker.rotateOrigin ?? rotateOrigin,
              alignment: marker.rotateAlignment ?? rotateAlignment,
              child: marker.builder(context),
            )
          : marker.builder(context);
      markerWidgets.add(
        Positioned(
          key: marker.key,
          width: marker.width,
          height: marker.height,
          left: pos.x - rightPortion,
          top: pos.y - bottomPortion,
          child: markerWidget,
        ),
      );
    }
    return Stack(
      children: markerWidgets,
    );
  }
}
