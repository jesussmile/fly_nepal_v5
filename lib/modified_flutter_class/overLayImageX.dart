import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:fly_nepal/experimental/resizable.dart';
import 'package:fly_nepal/experimental/triangle.dart';
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
    double opac = 0.3;
    return GestureDetector(
      onDoubleTap: () {
        mapInteraction = !mapInteraction;
        selectedChart = chartName;
        chosenPlate = chartName;
        provider.showResizeWid(!provider.showMapResizeWidget);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final containerSize = constraints.biggest;
          final triangleSize = containerSize.shortestSide * 0.2;
          final circleSize = containerSize.shortestSide * 0.25;
          //final rectangleSize = containerSize.shortestSide * 0.5;

          return Container(
            color: !mapInteraction && selectedChart == chartName
                ? const Color.fromARGB(255, 167, 247, 169)
                : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.fill,
                        color: Color.fromRGBO(255, 255, 255, opacity),
                        colorBlendMode: BlendMode.modulate,
                        gaplessPlayback: gaplessPlayback,
                      ),
                    ),
                  ),
                  !mapInteraction
                      ? Positioned.fill(
                          child: Center(
                            child: Listener(
                              onPointerMove: (details) {
                                if (details.delta.dx < 0 &&
                                    details.delta.dy < 0) {
                                  provider.moveTopLeft(); // Move top left
                                } else if (details.delta.dx > 0 &&
                                    details.delta.dy < 0) {
                                  provider.moveTopRight(); // Move top right
                                } else if (details.delta.dx > 0 &&
                                    details.delta.dy > 0) {
                                  provider
                                      .moveBottomRight(); // Move bottom right
                                } else if (details.delta.dx < 0 &&
                                    details.delta.dy > 0) {
                                  provider.moveBottomLeft(); // Move bottom left
                                } else if (details.delta.dx < 0) {
                                  provider.moveLeft(); // Move left
                                } else if (details.delta.dx > 0) {
                                  provider.moveRight(); // Move right
                                } else if (details.delta.dy < 0) {
                                  provider.moveUp(); // Move up
                                } else if (details.delta.dy > 0) {
                                  provider.moveDown(); // Move down
                                }
                              },
                              onPointerUp: (details) {
                                // printChartPosition();
                              },
                              child: Container(
                                height: circleSize,
                                width: circleSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      const Color.fromARGB(255, 215, 113, 105)
                                          .withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  !mapInteraction
                      ? Positioned(
                          top: 0,
                          right: 0,
                          child: ClipPath(
                            clipper: TriangleClipper(rotationAngle: 1.5 * pi),
                            child: Listener(
                              onPointerMove: (details) {
                                if (details.delta.dx > 0) {
                                  provider.zoomIn();
                                } else if (details.delta.dx < 0) {
                                  provider.zoomOut();
                                }
                              },
                              child: Container(
                                height: triangleSize,
                                width: triangleSize,
                                color: const Color.fromARGB(255, 215, 113, 105)
                                    .withOpacity(opac),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  !mapInteraction
                      ? Positioned(
                          bottom: 0,
                          left: 0,
                          child: ClipPath(
                            clipper: TriangleClipper(rotationAngle: pi),
                            child: Listener(
                              onPointerMove: (details) {
                                if (details.delta.dx < 0) {
                                  provider.zoomIn();
                                } else if (details.delta.dx > 0) {
                                  provider.zoomOut();
                                }
                              },
                              child: Container(
                                height: triangleSize,
                                width: triangleSize,
                                color: const Color.fromARGB(255, 215, 113, 105)
                                    .withOpacity(opac),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  !mapInteraction
                      ? Positioned(
                          bottom: 0,
                          right: 0,
                          child: ClipPath(
                            clipper: TriangleClipper(rotationAngle: 0),
                            child: Listener(
                              onPointerMove: (details) {
                                if (details.delta.dx > 0) {
                                  provider.zoomIn();
                                } else if (details.delta.dx < 0) {
                                  provider.zoomOut();
                                }
                              },
                              child: Container(
                                height: triangleSize,
                                width: triangleSize,
                                color: const Color.fromARGB(255, 215, 113, 105)
                                    .withOpacity(opac),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  !mapInteraction
                      ? Positioned(
                          top: 0,
                          left: 0,
                          child: ClipPath(
                            clipper: TriangleClipper(rotationAngle: 0.5 * pi),
                            child: Listener(
                              onPointerMove: (details) {
                                if (details.delta.dx < 0) {
                                  provider.zoomIn();
                                } else if (details.delta.dx > 0) {
                                  provider.zoomOut();
                                }
                              },
                              child: Container(
                                height: triangleSize,
                                width: triangleSize,
                                color: const Color.fromARGB(255, 215, 113, 105)
                                    .withOpacity(opac),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  !mapInteraction
                      ? Positioned(
                          left: 0,
                          top: containerSize.height * 0.4,

                          /// 2 -
                          // 50, // Adjust the position as needed
                          child: Listener(
                            onPointerMove: (details) {
                              if (details.delta.dx < 0) {
                                provider.dragLeft();
                              }
                              if (details.delta.dx > 0) {
                                provider.dragLeftback();
                              }
                            },
                            child: Container(
                              width: triangleSize / 3,
                              height: triangleSize,
                              color: const Color.fromARGB(255, 215, 113, 105)
                                  .withOpacity(
                                      opac), //Adjust the color as needed
                            ),
                          ),
                        )
                      : const SizedBox(),
                  !mapInteraction
                      ? Positioned(
                          right: 0,
                          top: containerSize.height * 0.4,

                          /// 2 -
                          //50, // Adjust the position as needed
                          child: Listener(
                            onPointerMove: (details) {
                              if (details.delta.dx > 0) {
                                provider.dragRight();
                              }
                              if (details.delta.dx < 0) {
                                provider.dragRightBack();
                              }
                            },
                            child: Container(
                              width: triangleSize / 3,
                              height: triangleSize,
                              color: const Color.fromARGB(255, 215, 113, 105)
                                  .withOpacity(
                                      opac), //Adjust the color as needed
                            ),
                          ),
                        )
                      : const SizedBox(),
                  !mapInteraction
                      ? Positioned(
                          top: 0,
                          right: containerSize.width * 0.4,

                          /// 2 -
                          //  50, // Adjust the position as needed
                          child: Listener(
                            onPointerMove: (details) {
                              if (details.delta.dy < 0) {
                                provider.dragUp();
                              }
                              if (details.delta.dy > 0) {
                                provider.dragUpBack();
                              }
                            },
                            child: Container(
                              width: triangleSize,
                              height: triangleSize / 3,
                              color: const Color.fromARGB(255, 215, 113, 105)
                                  .withOpacity(
                                      opac), //Adjust the color as needed
                            ),
                          ),
                        )
                      : const SizedBox(),
                  !mapInteraction
                      ? Positioned(
                          bottom: 0,
                          right: containerSize.width * 0.4, // / 2 -
                          //  50, // Adjust the position as needed
                          child: Listener(
                            onPointerMove: (details) {
                              if (details.delta.dy > 0) {
                                provider.dragDown();
                              }
                              if (details.delta.dy < 0) {
                                provider.dragDownBack();
                              }
                            },
                            child: Container(
                              width: triangleSize,
                              height: triangleSize / 3,
                              color: const Color.fromARGB(255, 215, 113, 105)
                                  .withOpacity(
                                      opac), //Adjust the color as needed
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          );
        },
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
