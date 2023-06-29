import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:fly_nepal/providers/MarkerListProvider.dart';
import 'package:fly_nepal/modified_flutter_class/markerQuadTree.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MarkerX {
  final String? airwayCode;
  final String? countryCode;
  final String? frequency;
  final String? name;
  final LatLng point;
  final String identifier;
  final Key? key;
  final double width;
  final double height;
  final Anchor anchor;
  final bool? rotate;
  final Offset? rotateOrigin;
  final AlignmentGeometry? rotateAlignment;
  final void Function(Canvas canvas, Offset offset) onDraw;
  final Stream<dynamic>? stream;
  final Function(LatLng, String)? onTap;
  MarkerX({
    required this.point,
    this.airwayCode,
    this.countryCode,
    this.frequency,
    this.name,
    this.key,
    this.width = 30.0,
    this.height = 30.0,
    this.rotate,
    required this.identifier,
    this.rotateOrigin,
    this.rotateAlignment,
    this.onTap,
    AnchorPos? anchorPos,
    required this.onDraw,
    this.stream,
  }) : anchor = Anchor.fromPos(
            anchorPos ?? AnchorPos.exactly(Anchor(0, 0)), width, height);
}

class MarkerLayerX extends StatefulWidget {
  final List<MarkerX> markers;
  final bool rotate;
  final Offset? rotateOrigin;
  final AlignmentGeometry? rotateAlignment;
  const MarkerLayerX({
    Key? key,
    this.markers = const [],
    this.rotate = false,
    this.rotateOrigin,
    this.rotateAlignment = Alignment.center,
  }) : super(key: key);
  @override
  State<MarkerLayerX> createState() => _MarkerLayerXState();
}

class _MarkerLayerXState extends State<MarkerLayerX> {
  late FlutterMapState map;
  late MarkerQuadtree markerQuadtree;
  List<MarkerX> visibleMarkers = [];
  final StreamController _markerStreamController = StreamController.broadcast();
  LatLngBounds? _cachedBounds;
  @override
  void initState() {
    super.initState();
    final markers = widget.markers;
    final bounds =
        Provider.of<MarkerListProvider>(context, listen: false).latLngB!;
    markerQuadtree = MarkerQuadtree(bounds, 5000); // adjust capacity as needed
    _putMarkers(bounds, markers);
    _listenToMarkerStream();
  }

  void _listenToMarkerStream() {
    if (widget.markers.any((marker) => marker.stream != null)) {
      _markerStreamController.stream.listen((_) {
        setState(() {});
      });
    }
  }

  void _putMarkers(LatLngBounds bounds, List<MarkerX> markers) {
    for (final marker in markers) {
      markerQuadtree.insert(marker);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    map = FlutterMapState.maybeOf(context)!;

    final newBound =
        Provider.of<MarkerListProvider>(context, listen: false).latLngB;
    if (newBound != _cachedBounds) {
      _cachedBounds = newBound;
      markerQuadtree =
          MarkerQuadtree(newBound!, 5000); // adjust capacity as needed
      _putMarkers(newBound, widget.markers);
      visibleMarkers = _getVisibleMarkers();
    }
  }

  List<MarkerX> _getVisibleMarkers() {
    return markerQuadtree.query(map.bounds);
  }

  @override
  Widget build(BuildContext context) {
    final newBound =
        Provider.of<MarkerListProvider>(context, listen: false).latLngB;
    if (newBound != _cachedBounds) {
      _cachedBounds = newBound;
      markerQuadtree =
          MarkerQuadtree(newBound!, 5000); // adjust capacity as needed
      _putMarkers(newBound, widget.markers);
      visibleMarkers = _getVisibleMarkers();
    }
    final markerWidgets = visibleMarkers.map((marker) {
      final pxPoint = map.project(marker.point);
      final rightPortion = marker.width - marker.anchor.left;
      final leftPortion = marker.anchor.left;
      final bottomPortion = marker.height - marker.anchor.top;
      final topPortion = marker.anchor.top;
      final pos = pxPoint - map.pixelOrigin;
      final markerWidget = (marker.rotate ?? widget.rotate)
          ? Transform.rotate(
              angle: -map.rotationRad,
              origin: marker.rotateOrigin ?? widget.rotateOrigin,
              alignment: marker.rotateAlignment ?? widget.rotateAlignment,
              child: CustomPaint(
                painter: _MarkerPainter(marker.onDraw),
              ),
            )
          : CustomPaint(
              painter: _MarkerPainter(marker.onDraw),
            );
      return Positioned(
        key: marker.key,
        width: marker.width,
        height: marker.height,
        left: pos.x - rightPortion,
        top: pos.y - bottomPortion,
        child: marker.stream == null
            ? markerWidget
            : StreamBuilder(
                stream: _markerStreamController.stream,
                builder: (context, snapshot) {
                  return markerWidget;
                },
              ),
      );
    }).toList();
    return Stack(
      children: markerWidgets,
    );
  }

  @override
  void dispose() {
    _markerStreamController.close();
    super.dispose();
  }
}

class _MarkerPainter extends CustomPainter {
  final void Function(Canvas canvas, Offset offset) onDraw;
  const _MarkerPainter(this.onDraw);
  @override
  void paint(Canvas canvas, Size size) => onDraw(canvas, Offset.zero);
  @override
  bool shouldRepaint(_MarkerPainter oldDelegate) => false;
}
