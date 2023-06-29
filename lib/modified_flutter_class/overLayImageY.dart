import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

/// Base class for all overlay images.
abstract class BaseOverlayImageY {
  ImageProvider get imageProvider;
  double get opacity;
  bool get gaplessPlayback;
  Positioned buildPositionedForOverlay(FlutterMapState map);
  DraggableZoomableRotatableImage buildImageForOverlay(
      LatLng topLeft, LatLng bottomLeft, LatLng bottomRight) {
    return DraggableZoomableRotatableImage(
      imageProvider: imageProvider,
      bottomLeftCorner: bottomLeft,
      bottomRightCorner: bottomRight,
      // onPositionChanged: (LatLng(0,0), LatLng(0,0), LatLng(0,0)) {},
      topLeftCorner: topLeft,
    );
  }
}

@override
class RotatedOverlayImageY extends BaseOverlayImageY {
  @override
  final ImageProvider imageProvider;
  final dynamic chartName;
  final LatLng topLeftCorner, bottomLeftCorner, bottomRightCorner;
  @override
  final double opacity;
  @override
  final bool gaplessPlayback;

  /// The filter quality when rotating the image.
  final FilterQuality? filterQuality;
  RotatedOverlayImageY(
      {required this.imageProvider,
      required this.topLeftCorner,
      required this.bottomLeftCorner,
      required this.bottomRightCorner,
      required this.chartName,
      this.opacity = 1.0,
      this.gaplessPlayback = false,
      this.filterQuality = FilterQuality.medium});
  @override
  Positioned buildPositionedForOverlay(FlutterMapState map) {
    final pxTopLeft = map.project(topLeftCorner) - map.pixelOrigin;
    final pxBottomRight = map.project(bottomRightCorner) - map.pixelOrigin;
    final pxBottomLeft = map.project(bottomLeftCorner) - map.pixelOrigin;
    // calculate pixel coordinate of top-right corner by calculating the
    // vector from bottom-left to top-left and adding it to bottom-right
    final pxTopRight = (pxTopLeft - pxBottomLeft + pxBottomRight);
    // update/enlarge bounds so the new corner points fit within
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
            child: buildImageForOverlay(
                topLeftCorner, bottomLeftCorner, bottomRightCorner)));
  }
}

class OverlayImageLayerY extends StatelessWidget {
  final List<BaseOverlayImageY> overlayImages;
  const OverlayImageLayerY({super.key, this.overlayImages = const []});
  @override
  Widget build(BuildContext context) {
    final map = FlutterMapState.maybeOf(context)!;
    return ClipRect(
      child: Stack(
        children: <Widget>[
          for (var overlayImage in overlayImages)
            overlayImage.buildPositionedForOverlay(map),
        ],
      ),
    );
  }
}

class DraggableZoomableRotatableImage extends StatefulWidget {
  final ImageProvider imageProvider;
  final LatLng topLeftCorner;
  final LatLng bottomLeftCorner;
  final LatLng bottomRightCorner;
  //final Function(LatLng, LatLng, LatLng) onPositionChanged;
  const DraggableZoomableRotatableImage({
    super.key,
    required this.imageProvider,
    required this.topLeftCorner,
    required this.bottomLeftCorner,
    required this.bottomRightCorner,
    //  required this.onPositionChanged
  });
  @override
  _DraggableZoomableRotatableImageState createState() =>
      _DraggableZoomableRotatableImageState();
}

class _DraggableZoomableRotatableImageState
    extends State<DraggableZoomableRotatableImage> {
  double _scale = 1.0;
  double _rotation = 0.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  int _fingerCount = 0;
  bool _canDrag = false;
  void _updatePosition() {
    final map = FlutterMapState.maybeOf(context)!;
    final pxTopLeft = map.project(widget.topLeftCorner) - map.pixelOrigin;
    final pxBottomRight =
        map.project(widget.bottomRightCorner) - map.pixelOrigin;
    final pxBottomLeft = map.project(widget.bottomLeftCorner) - map.pixelOrigin;
    LatLng topLatlng = map.unproject(pxTopLeft, map.zoom);
    print("TopLatlng  $topLatlng");
    map.unproject(pxBottomLeft);
    map.unproject(pxBottomRight);
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onDoubleTap: () {
              setState(() {
                _canDrag = !_canDrag;
                print(widget.topLeftCorner);
                print(widget.bottomLeftCorner);
                print(widget.bottomRightCorner);
              });
            },
            onScaleStart: (details) {
              if (details.pointerCount == 1 && _canDrag) {
                _previousOffset = details.focalPoint;
                //_canDrag = true;
              }
              _fingerCount = details.pointerCount;
            },
            onScaleUpdate: (details) {
              if (_fingerCount == 1 && _canDrag) {
                final delta = details.focalPoint - _previousOffset;
                setState(() {
                  _offset += delta;
                });
                _previousOffset = details.focalPoint;
              }
            },
            onScaleEnd: (details) {
              _fingerCount = 0;
              _updatePosition();
            },
            child: Transform.translate(
              offset: _offset,
              child: Transform.rotate(
                angle: _rotation,
                child: Transform.scale(
                  scale: _scale,
                  child: Image(image: widget.imageProvider),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: _canDrag,
          child: Positioned(
            right: 10.0,
            top: 10.0,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _rotation += pi / 350;
                    });
                  },
                  child: const Icon(Icons.rotate_right),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _rotation -= pi / 350;
                    });
                  },
                  child: const Icon(Icons.rotate_left),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _scale *= 1.01;
                    });
                  },
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _scale *= 0.99;
                    });
                  },
                  child: const Icon(Icons.zoom_out),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
