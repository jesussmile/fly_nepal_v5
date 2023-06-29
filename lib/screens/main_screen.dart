import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fly_nepal/colors/custom_colors.dart';
import 'package:fly_nepal/modified_flutter_class/load_chart_btn.dart';
import 'package:fly_nepal/services/chip_manager.dart';
import 'package:fly_nepal/model/TapMarkers.dart';
import 'package:fly_nepal/providers/MarkerListProvider.dart';
import 'package:fly_nepal/providers/provider_service.dart';
import 'package:fly_nepal/widgets/scale_plugin.dart';
import 'package:fly_nepal/screens/dropdown_asset_chart.dart';
import 'package:fly_nepal/widgets/avatar_glow.dart';
import 'package:fly_nepal/screens/flight_plan.dart';
import 'package:fly_nepal/widgets/flutterMap_zoom_button.dart';
import 'package:fly_nepal/screens/route_pop_up.dart';
import 'package:fly_nepal/widgets/tapListMarker.dart';
import 'package:fly_nepal/modified_flutter_class/MarkerY.dart';
import 'package:fly_nepal/modified_flutter_class/MarkerX.dart';
import 'package:fly_nepal/modified_flutter_class/overLayImageX.dart';
import 'package:fly_nepal/modified_flutter_class/polyLineX.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const maxMarkersCount = 20000;

class _MyHomePageState extends State<MyHomePage> {
  bool showPopup = false;
  double tolerance = 0.005;
  double? zoomLevel = 9;
  double _value = 0.001; // Initialize the value to 0.001
  final _mapKey = GlobalKey<FlutterMapState>();
  final lines = <Polyline>[];
  final TextEditingController _chipTextController = TextEditingController();
  int _sliderVal = maxMarkersCount ~/ 10;
  late bool _isExpanded = false;
  late bool _isExpandedInfo = false;
  late bool _isHideWaypoints = false;
  late double bottomLat; // = 26.7469012;
  late double leftTopBotLon; //= 84.7436897;
  late double righttopBotLon; // = 85.8364298;
  late double topLat; // = 28.0615487;
  late final MapController flutterMapController = MapController();
  late final FlutterMapState flutterMapState;
  late final Stream<Position?> _geolocatorStream;
  late LatLng bottomLeftCorner; //= LatLng(26.7669688, 84.7536897);
  late LatLng bottomLeftCorner1; //= LatLng(26.7669688, 84.7536897);
  late LatLng bottomRightCorner;
  late LatLng bottomRightCorner1;
  late LatLng topLeftCorner;
  late LatLng topLeftCorner1;
  late Stream<LocationMarkerPosition> positionStream;
  late String _accuracy = "";
  late String _altitude = "";
  late String _curTime = "";
  late String _heading = "";
  late String _speed = "";
  late String _speedAccuracy = "";
  late String _timeStamp = "";
  LatLngBounds latlngBounds =
      LatLngBounds(const LatLng(0, 0), const LatLng(0, 0));
  List<Marker> apMarker = [];
  List<MarkerX> allMarkers = [];
  List<MarkerX> wayPointsMarkers = [];
  List<MarkerY> allMarkersY = [];
  List<MarkerY> wayPointsMarkersY = [];
  List<LatLng> polyAirPlaneRoute = [];
  //String _movingChipName = "";
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller4 = TextEditingController();
  TextEditingController textFieldController = TextEditingController();
  bool _downloading = false;
  late StreamSubscription<DownloadProgress> _progressListener;
  double _downloadProgress = 0;

  @override
  void dispose() {
    _progressListener.cancel();
    super.dispose();
  }

  Future<void> _startDownload() async {
    final region = RectangleRegion(LatLngBounds(
      LatLng(30.448027, 80.058577), // North West //Nepal
      LatLng(26.347162, 88.194040), // South East
      //LatLng(28.246918, 88.730003),
      // LatLng(26.679180, 91.679941)),
    ));
    final downloadable = region.toDownloadable(
      4, // Minimum Zoom
      14, // Maximum Zoom
      TileLayer(
        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        subdomains: const ['a', 'b', 'c'],
      ),
      // Additional Parameters
    );
    final tilesToDownload =
        await FMTC.instance('mapStore').download.check(downloadable);
    print('Number of tiles to download: $tilesToDownload');
    setState(() {
      _downloading = true;
    });
    _progressListener = FMTC
        .instance('mapStore')
        .download
        .startForeground(
          region: downloadable,
          bufferMode: DownloadBufferMode.tiles,
        )
        .listen((progress) {
      print(progress.successfulTiles);
      final percentage = (progress.successfulTiles / progress.maxTiles) * 100;

      setState(() {
        _downloadProgress = percentage;
      });
      //print('Download progress: $percentage%');
      if (percentage == 100) {
        setState(() {
          _downloading = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    //flutterMapState = FlutterMapState.maybeOf(context)!;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    MarkerListProvider markerListProvider =
        Provider.of<MarkerListProvider>(context, listen: false);
    markerListProvider.loadBorder(); //border
    // markerListProvider.loadAssets(context);
    markerListProvider.loadAirportMarkers(); //airport
    markerListProvider.loadNavAidMarkers(); //navaid
    markerListProvider.loadWayAirwayLinesMarkers(); //airway
    markerListProvider
        .loadWayPointsMarkers(); //large small markers other than reporting
    markerListProvider.loadWayReportingPointMarkers(); //reporting
    _chipTextController.addListener(() {
      if (_chipTextController.text.endsWith(' ')) {
        //_addChip();
        ChipManager.addChip(context, _chipTextController, 'user');
      }
    });
    const factory = LocationMarkerDataStreamFactory();
    _geolocatorStream =
        factory.defaultPositionStreamSource().asBroadcastStream();
    _geolocatorStream.listen((position) {
      if (position != null) {
        setState(() {
          polyAirPlaneRoute.add(LatLng(position.latitude, position.longitude));
          //print(polyAirPlaneRoute);
          _altitude = ((position.altitude * 3.281).toStringAsFixed(0));
          _speed = ((position.speed * 1.94384).toStringAsFixed(0));
          _accuracy = ("${position.accuracy.toStringAsFixed(0)} m");
          _heading = (position.heading.toStringAsFixed(0));
          _speedAccuracy = (" ${position.speedAccuracy.toStringAsFixed(1)}");
          var now = DateTime.now();
          var formatterTime = DateFormat('kk:mm:ss');
          _curTime = formatterTime.format(now);
          _timeStamp =
              ("${position.timestamp!.hour}:${position.timestamp!.minute}:${position.timestamp!.second}");
        });
      }
    });
  }

  double calculateDistance(LatLng a, LatLng b) {
    return const Distance().distance(a, b);
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProviderService>(context, listen: false);
    const factory = LocationMarkerDataStreamFactory();
    //flutter: screenHeight 834.0 screenWidth 1112.0}
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    // print(
    //     'screenHeight ${ScreenHeight.toString()} screenWidth ${ScreenWidth.toString()}}');
    return OrientationBuilder(builder: (ctxx, orientation) {
      final isLandscape = orientation == Orientation.landscape;
      return Scaffold(
          // appBar: AppBar,
          body: Column(
        children: [
          Container(
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 62, 84, 122)),
            height: screenHeight * 0.1,
            width: screenWidth,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 40, 0, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    // ignore: prefer_const_constructors
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 62, 84, 122))),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        // ignore: prefer_const_constructors
                        child: Text(
                          'Flight Plan',
                          // ignore: prefer_const_constructors
                          style: TextStyle(color: Colors.white),
                        )),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 62, 84, 122))),
                        onPressed: () {
                          setState(() {
                            _isExpandedInfo = !_isExpandedInfo;
                          });
                        },
                        // ignore: prefer_const_constructors
                        child: Text(
                          'Info',
                          // ignore: prefer_const_constructors
                          style: TextStyle(color: Colors.white),
                        )),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 62, 84, 122))),
                        onPressed: () {
                          setState(() {
                            // _isHideWaypoints = !_isHideWaypoints;
                            _isHideWaypoints = !_isHideWaypoints;
                          });
                        },
                        // ignore: prefer_const_constructors
                        child: Text(
                          'Show WayPoints',
                          // ignore: prefer_const_constructors
                          style: TextStyle(color: Colors.white),
                        )),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 62, 84, 122),
                        ),
                      ),
                      onPressed: () {
                        // print('${FlutterMapState.maybeOf(context)!.center}');
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Asset Files'),
                              content: SizedBox(
                                width: 300,
                                child: FolderDropdown(
                                  flutterMapC: flutterMapController,
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text(
                        'Asset Files',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 62, 84, 122),
                        ),
                      ),
                      onPressed: () {
                        Provider.of<ProviderService>(context, listen: false)
                            .overlayImagesX
                            .clear();
                      },
                      child: const Text(
                        'Clear Chart',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 62, 84, 122),
                        ),
                      ),
                      onPressed: () {
                        getImageSize('VORD02_J.png', context);
                      },
                      child: const Text(
                        'Load Chart Experimental',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 20,
                        width: 200,
                        child: Slider(
                          max: 0.020,
                          min: 0.001,
                          value: _value,
                          onChanged: (value) {
                            setState(() {
                              _value = value;
                            });
                            // print(value);
                            Provider.of<ProviderService>(context, listen: false)
                                .setTolerance(value);
                          },
                        ),
                      ),
                    ),
                    Text(
                      '  Map Download  ${_downloadProgress.toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    ElevatedButton(
                        onPressed: _startDownload, child: Text('Dowload Map'))
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  // bottom: 0,
                  child: SizedBox(
                    height: isLandscape ? screenHeight * 0.9 : 92.h,
                    width: isLandscape ? screenWidth : 100.w,
                    child: FlutterMap(
                      key: _mapKey,
                      mapController: flutterMapController,
                      options: MapOptions(
                          onMapReady: () {
                            Provider.of<ProviderService>(context, listen: false)
                                .isMapReady(true);
                          },
                          onLongPress: (tapPosition, point) {
                            if (mapInteraction == true) {
                              final List<TapMarkers> nearbyMarkers = [];
                              // print(
                              //     'inside FlutterMap ${TapMarkers.allMarkers.length}');
                              //Calculate the distance between the tap point and each marker
                              for (final marker in TapMarkers.allMarkers) {
                                //print(marker.latitude);
                                // print(marker.longitude);
                                final distance = calculateDistance(
                                    LatLng(point.latitude, point.longitude),
                                    LatLng(marker.latitude, marker.longitude));
                                if (distance < 27780) {
                                  // Change this threshold to adjust the distance at which markers are shown
                                  nearbyMarkers.add(marker);
                                }
                              }
                              // nearbyMarkers =
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Nearby markers'),
                                  content: MarkerListWidget(nearbyMarkers),
                                ),
                              );
                            }
                          },
                          onPositionChanged: ((position, hasGesture) {
                            zoomLevel = position.zoom;
                            latlngBounds = position.bounds!;
                            //print("zoomLevel  $zoomLevel");
                            // setState(() {});
                            Provider.of<MarkerListProvider>(context,
                                    listen: false)
                                .setZoom(zoomLevel!, latlngBounds);
                          }),
                          center: const LatLng(27.7000, 84.3333),
                          // swPanBoundary: LatLng(26.347892,
                          //     80.067963), // Southwest corner of Nepal
                          // nePanBoundary: LatLng(30.446945, 88.201523),
                          zoom: 7,
                          //  onLongPress: Provider.of<MarkerListProvider>(context, listen: false).loadMarkers(),
                          minZoom: 6,
                          // adaptiveBoundaries: true,
                          interactiveFlags: mapInteraction
                              ? InteractiveFlag.pinchZoom |
                                  InteractiveFlag.drag |
                                  InteractiveFlag.flingAnimation
                              : InteractiveFlag.none //InteractiveFlag.none
                          // InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                          ),
                      nonRotatedChildren: [
                        const LoadChart(
                          alignment: Alignment.bottomRight,
                        ),
                        // ignore: prefer_const_constructors
                        FlutterMapZoomButtonsX(
                          minZoom: 4,
                          maxZoom: 19,
                          mini: true,
                          padding: 10,
                          alignment: Alignment.bottomLeft,
                        ),
                        ScaleLayerWidget(
                            options: ScaleLayerPluginOption(
                                lineColor: Colors.white,
                                lineWidth: 2,
                                textStyle: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                                padding: const EdgeInsets.only(top: 30))),
                      ],
                      children: [
                        TileLayer(
                          //tileProvider: CachedTileProvider(),
                          urlTemplate:
                              'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoicGFubmFtIiwiYSI6ImNsZXBjbHZhcDAxa2szem1vZHg2ZHdzMTgifQ.ZwzH7NOdjAJwf15LlAZUGQ',
                          // ignore: prefer_const_literals_to_create_immutables
                          additionalOptions: {
                            //'id': 'mapbox/streets-v11',
                            // 'id': 'mapbox/outdoors-v11'
                            //'id': 'mapbox/satellite-v9'
                            'id': 'mapbox/dark-v11'
                          },
                          userAgentPackageName: 'com.example.app',
                          tileProvider:
                              FMTC.instance('mapStore').getTileProvider(),
                        ),
                        // MarkerLayerX(markers: wayPointsMarkers),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                                //bharatpur
                                borderColor: Colors.white.withOpacity(0.5),
                                point: const LatLng(27.678056, 84.429444),
                                color: const Color.fromARGB(255, 111, 240, 242)
                                    .withOpacity(0.5),
                                borderStrokeWidth: 2,
                                useRadiusInMeter: true,
                                radius: 18520)
                          ],
                        ),

                        CircleLayer(
                          circles: [
                            CircleMarker(
                                //surkhet
                                borderColor: Colors.white.withOpacity(0.5),
                                point: const LatLng(28.585833, 81.635278),
                                color: const Color.fromARGB(255, 111, 240, 242)
                                    .withOpacity(0.5),
                                borderStrokeWidth: 2,
                                useRadiusInMeter: true,
                                radius: 9260)
                          ],
                        ),
                        Consumer<MarkerListProvider>(builder:
                            (BuildContext context, value, Widget? child) {
                          return IgnorePointer(
                            child: PolylineLayer(
                                polylines: value.borders
                                    .map((border) => Polyline(
                                        points: border,
                                        color: Colors.blue,
                                        strokeWidth: 5.0))
                                    .toList()),
                          );
                        }),
                        Consumer<MarkerListProvider>(builder:
                            (BuildContext context, value, Widget? child) {
                          if (value.mapZoom > 7.6) {
                            return IgnorePointer(
                              child: PolylineLayer(
                                  polylineCulling: true,
                                  polylines: value.airwayPolyLine
                                      .map((border) => Polyline(
                                          points: border,
                                          color: Colors.blue,
                                          strokeWidth: 0.3))
                                      .toList()),
                            );
                          } else {
                            return const PolygonLayer(
                              polygons: [],
                            );
                          }
                        }),
                        IgnorePointer(
                          child: PolylineLayerX(
                            // polylineCulling: true,
                            polylines: [
                              PolylineX(
                                points: [], // customRoute, //VNKT_VNVT,
                                isDotted: false,
                                strokeWidth: 5,
                                borderColor: Colors.black.withOpacity(0.5),
                                borderStrokeWidth: 2,
                                color: const Color.fromARGB(255, 3, 227, 248)
                                    .withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                        IgnorePointer(
                          child: PolylineLayer(
                            polylines: [
                              Polyline(
                                points: polyAirPlaneRoute, //VNKT_VNVT,
                                isDotted: false,
                                strokeWidth: 5,
                                color: Colors.blue.shade400.withOpacity(0.5),
                                // borderColor: Colors.black45, //.withOpacity(0.5),
                                //borderStrokeWidth: 2
                                // gradientColors: gradientColors2,
                              ),
                            ],
                          ),
                        ),
                        IgnorePointer(
                          child: PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [], //KTM_TMA, //VNKT_VNVT,
                                isDotted: false,
                                strokeWidth: 5,
                                color: Colors.blue.shade400.withOpacity(0.5),
                                // borderColor: Colors.black45, //.withOpacity(0.5),
                                //borderStrokeWidth: 2
                                // gradientColors: gradientColors2,
                              ),
                            ],
                          ),
                        ),
                        // MarkerLayer(markers: [],)
                        Consumer<MarkerListProvider>(builder:
                            (BuildContext context, value, Widget? child) {
                          if (value.mapZoom > 6.6) {
                            return MarkerLayerX(markers: value.navAidMarkers);
                          } else {
                            return const MarkerLayerX(
                              markers: [],
                            );
                          }
                          // );
                        }),
                        Consumer<MarkerListProvider>(builder:
                            (BuildContext context, value, Widget? child) {
                          if (value.mapZoom > 6.3) {
                            return MarkerLayerX(markers: value.airportMarkers);
                          } else {
                            return const MarkerLayerX(
                              markers: [],
                            );
                          }
                          // );
                        }),
                        Selector<MarkerListProvider, List<MarkerX>>(
                          selector: (context, provider) {
                            if (provider.mapZoom > 7.2 &&
                                provider.mapZoom <= 10.1) {
                              return provider.reportingPointsMarkers;
                              // return provider.reportingFixMarkers;
                            } else {
                              return [];
                            }
                          },
                          builder: (context, markers, child) {
                            // if (markers.isNotEmpty) {
                            return MarkerLayerX(markers: markers);
                            //  } else {
                            //   return const MarkerLayer(markers: []);
                            //  }
                          },
                        ),
                        if (_isHideWaypoints)
                          Selector<MarkerListProvider, List<MarkerX>>(
                            selector: (context, provider) {
                              if (provider.mapZoom > 9 &&
                                  provider.mapZoom <= 10.1) {
                                //print(_isHideWaypoints);
                                return provider.wayPointsMarkers;
                              } else {
                                return [];
                              }
                            },
                            builder: (context, markers, child) {
                              return MarkerLayerX(markers: markers);
                            },
                          ),
                        Consumer<ProviderService>(
                            builder: (BuildContext ctx, value, Widget? child) {
                          //if (value.mapReady = true) {
                          return OverlayImageLayerX(
                            overlayImages: value.overlayImagesX,
                          );
                          //  } else {
                          //   return const SizedBox();
                          // }
                        }),
                        IgnorePointer(
                          child: Consumer<MarkerListProvider>(
                              builder: (BuildContext context, value, child) {
                            return PolylineLayerX(polylines: [
                              PolylineX(
                                points: value.goAroundLatLng,
                                isDotted: false,
                                strokeWidth: 5,
                                borderColor: Colors.black.withOpacity(0.5),
                                borderStrokeWidth: 2,
                                color: const Color.fromARGB(255, 247, 201, 131)
                                    .withOpacity(0.5),
                              )
                            ]);
                          }),
                        ),
                        IgnorePointer(child: Consumer<MarkerListProvider>(
                            builder: (BuildContext context, value, child) {
                          List<LatLng> totalUserLatLng = value.totalUserLatLng
                              .expand((element) => element)
                              .toList();
                          // int totalPoints = totalUserLatLng.length;
                          return PolylineLayerX(polylines: [
                            PolylineX(
                                points: totalUserLatLng,
                                isDotted: false,
                                strokeWidth: 5,
                                borderColor: Colors.black, //.withOpacity(0.5),
                                borderStrokeWidth: 2,
                                color: !mapInteraction
                                    ? const Color.fromARGB(255, 246, 96, 196)
                                        .withOpacity(0.5)
                                    : const Color.fromARGB(255, 246, 96, 196)
                                        .withOpacity(0.5))
                          ]);
                        })),
                        Consumer<MarkerListProvider>(builder:
                            (BuildContext context, value, Widget? child) {
                          return MarkerLayer(markers: value.customMarker);
                        }),
                        IgnorePointer(
                          child: PolylineLayer(
                            polylines: [
                              Polyline(
                                points:
                                    polyAirPlaneRoute, //KTM_TMA, //VNKT_VNVT,
                                isDotted: false,
                                strokeWidth: 5,
                                color: Colors.green,
                                borderColor: Colors.white,
                                borderStrokeWidth: 2,
                                // borderColor: Colors.black45, //.withOpacity(0.5),
                                //borderStrokeWidth: 2
                                // gradientColors: gradientColors2,
                              ),
                            ],
                          ),
                        ),
                        IgnorePointer(
                          child: CurrentLocationLayer(
                            positionStream:
                                factory.fromGeolocatorPositionStream(
                              stream: _geolocatorStream,
                            ),
                            style: LocationMarkerStyle(
                                markerDirection: MarkerDirection.heading,
                                markerSize: const Size.square(55),
                                marker: AvatarGlow(
                                    //showTwoGlows: true,
                                    glowColor:
                                        Color.fromARGB(255, 107, 107, 195),
                                    endRadius: 500,
                                    child: SvgPicture.asset(
                                      "assets/plane2.svg",
                                      // color: const Color.fromARGB(
                                      //     255, 57, 239, 78),
                                      height: 45,
                                    ))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Positioned(top: 50, child: BottomWidget()),
                Consumer<ProviderService>(
                  builder: (BuildContext context, value, Widget? child) {
                    if (value.showMapResizeWidget) {
                      return Positioned(
                        top: 20,
                        right: 0,
                        child: Container(
                          color: Colors.transparent,
                          height: 20.h,
                          width: 30.h,
                          child: Stack(
                            children: [
                              Positioned(
                                  top: -5,
                                  right: 145,
                                  child: moveUp(chosenPlate)),
                              Positioned(
                                  top: 30,
                                  left: 60,
                                  child: moveLeft(chosenPlate)),
                              Positioned(
                                  top: 30,
                                  right: 80,
                                  child: moveRight(chosenPlate)),
                              Positioned(
                                  top: 65,
                                  right: 145,
                                  child: moveDown(chosenPlate)),
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child: resetBtn(chosenPlate)),
                              Positioned(
                                  top: 65, right: 0, child: printChartPos()),
                              Positioned(
                                top: 0,
                                child: zoomIn(chosenPlate),
                              ),
                              Positioned(
                                top: 65,
                                child: zoomOut(chosenPlate),
                              ),
                              Positioned(
                                  top: 110,
                                  right: 145,
                                  child: dragUp(chosenPlate)),
                              Positioned(
                                  top: 140,
                                  left: 60,
                                  child: dragLeft(chosenPlate)),
                              Positioned(
                                  top: 140,
                                  right: 80,
                                  child: dragRight(chosenPlate)),
                              Positioned(
                                  top: 175,
                                  right: 145,
                                  child: dragDown(chosenPlate)),
                              //BottomWidget()
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                Consumer<ProviderService>(
                  builder: (BuildContext context, value, Widget? child) {
                    if (value.showMapResizeWidget) {
                      return Positioned(
                        top: 250,
                        right: 10,
                        child: GestureDetector(
                          onScaleUpdate: (details) {
                            double scaleFactor = details.scale;
                            if (scaleFactor > 1) {
                              print("zoom in");
                              provider.zoomIn();
                            } else if (scaleFactor < 1) {
                              provider.zoomOut();
                              print("zoom out");
                            }
                            if (details.focalPointDelta.dx < 0) {
                              provider.moveLeft();
                              print("move left");
                            } else if (details.focalPointDelta.dx > 0) {
                              provider.moveRight();
                              print("move right ");
                            } else if (details.focalPointDelta.dy < 0) {
                              provider.moveUp();
                              print("zoom up");
                            } else if (details.focalPointDelta.dy > 0) {
                              provider.moveDown();
                              print("zoom down");
                            }
                          },
                          onScaleEnd: (details) {
                            printChartPosition();
                          },
                          child: Transform.scale(
                            scale: 1.0,
                            child: Container(
                              height: 20.h,
                              width: 30.w,
                              color: const Color.fromARGB(255, 233, 176, 176),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                Consumer<ProviderService>(
                    builder: (BuildContext context, value, Widget? child) {
                  if (value.showMapResizeWidget) {
                    return Positioned(
                        top: 470,
                        right: 0,
                        child: Container(
                          color: Colors.white,
                          height: 15.h,
                          width: 30.w,
                          child: TextFormField(
                            maxLines: 8,
                            controller: controller1,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.all(8.0),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ));
                  } else {
                    return Container();
                  }
                }),
                // if (_isExpanded) FlightPlanContainer(),
                if (_isExpanded)
                  FlightPlan(
                      procedure: procedure,
                      departure: departure,
                      arrival: arrival,
                      clear: clear,
                      chipTextController: _chipTextController),
                if (_isExpandedInfo) BottonInfo(orientation, isLandscape),
              ],
            ),
          ),
        ],
      ));
    });
  }

  List<Widget> _buildInfoWidgets() {
    final List<String> labels = [
      "GPS ALT",
      "GS",
      "HDG",
      "Accuracy",
      "SPD ACY",
      "UTC",
      "Time"
    ];
    final List<String> data = [
      _altitude,
      _speed,
      _heading,
      _accuracy,
      _speedAccuracy,
      _timeStamp,
      _curTime
    ];
    return List.generate(
      labels.length,
      (index) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            labels[index],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              width: 13.w,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(5),
              child: Center(
                child: Text(
                  data[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Positioned BottonInfo(Orientation orientation, bool landscape) {
    return Positioned(
      bottom: 0,
      left: 0,
      child: Container(
        color: CustomColor.darkBlue.color,
        height: 9.h,
        width: landscape ? 134.w : 100.w,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildInfoWidgets(),
          ),
        ),
      ),
    );
  }

  ElevatedButton moveLeft(dynamic plateName) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      onPressed: () {
        Provider.of<ProviderService>(context, listen: false).moveLeft();
        setImage();
        // printChartPosition();
      },
      child: const Icon(Icons.arrow_left),
    );
  }

  ElevatedButton moveDown(dynamic plateName) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      onPressed: () {
        Provider.of<ProviderService>(context, listen: false).moveDown();
        //setState(() {});
        setImage();
        // printChartPosition();
      },
      child: const Icon(Icons.arrow_drop_down),
    );
  }

  ElevatedButton moveUp(dynamic plateName) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      onPressed: () {
        Provider.of<ProviderService>(context, listen: false).moveUp();
        setImage();
      },
      child: const Icon(Icons.arrow_drop_up),
    );
  }

  ElevatedButton moveRight(dynamic plateName) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      onPressed: () {
        Provider.of<ProviderService>(context, listen: false).moveRight();
        //   setState(() {});
        setImage();
        //printChartPosition();
      },
      child: const Icon(Icons.arrow_right),
    );
  }

  ElevatedButton dragLeft(dynamic plateName) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      onPressed: () {
        Provider.of<ProviderService>(context, listen: false).dragLeft();
        // botR[plateName]!.longitude -= tolerance;
        //setImage();
        setImage();
        // printChartPosition();
      },
      child: const Icon(Icons.arrow_left),
    );
  }

  ElevatedButton dragDown(dynamic plateName) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      onPressed: () {
        //topL[plateName]!.latitude -= tolerance;
        Provider.of<ProviderService>(context, listen: false).dragDown();
        //setState(() {});
        setImage();
        // printChartPosition();
      },
      child: const Icon(Icons.arrow_drop_down),
    );
  }

  ElevatedButton dragUp(dynamic plateName) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      onPressed: () {
        Provider.of<ProviderService>(context, listen: false).dragUp();
        // botL[plateName]!.latitude += tolerance;
        //  botR[plateName]!.latitude += tolerance;
        //   setState(() {});
        setImage();
        // printChartPosition();
      },
      child: const Icon(Icons.arrow_drop_up),
    );
  }

  ElevatedButton dragRight(dynamic plateName) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      onPressed: () {
        //topL[plateName]!.longitude += tolerance;
        //botL[plateName]!.longitude += tolerance;
        Provider.of<ProviderService>(context, listen: false).dragRight();
        //   setState(() {});
        setImage();
        //printChartPosition();
      },
      child: const Icon(Icons.arrow_right),
    );
  }

  ElevatedButton zoomIn(dynamic plateName) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      onPressed: () {
        Provider.of<ProviderService>(context, listen: false).zoomIn();
        setImage();
        //printChartPosition();
      },
      child: const Icon(Icons.zoom_in),
    );
  }

  ElevatedButton zoomOut(dynamic plateName) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      onPressed: () {
        // Decrease the tolerance by a factor of 2
        // Move the points towards northwest
        Provider.of<ProviderService>(context, listen: false).zoomOut();
        //   setState(() {});
        setImage();
        // printChartPosition();
      },
      child: const Icon(Icons.zoom_out),
    );
  }

  void printChartPosition() {
    print(
        "TOP LEFT   $chosenPlate: LatLng(${topL[chosenPlate]!.latitude}, ${topL[chosenPlate]!.longitude}),");
    print(
        "BOTTOM LEFT $chosenPlate: LatLng( ${botL[chosenPlate]!.latitude}, topL[$chosenPlate]!.longitude),");
    print(
        "BOTTOM RIGHT $chosenPlate: LatLng(botL[$chosenPlate]!.latitude, ${botR[chosenPlate]!.longitude}),");
    controller1.text = '$chosenPlate\n'
        'TL-LatLng(${topL[chosenPlate]!.latitude}, ${topL[chosenPlate]!.longitude})\n'
        'BL-LatLng(${botL[chosenPlate]!.latitude}, ${topL[chosenPlate]!.longitude})\n'
        'BR-LatLng(${botL[chosenPlate]!.latitude}, ${botR[chosenPlate]!.longitude})';
    // print(
    //     "TOP LEFT   $chosenPlate: LatLng(${topL[chosenPlate]!.latitude}, ${topL[chosenPlate]!.longitude})");
    // print(
    //     "BOTTOM LEFT $chosenPlate: LatLng( ${botL[chosenPlate]!.latitude} ${botL[chosenPlate]!.longitude})");
    // print(
    //     "BOTTOM RIGHT $chosenPlate: LatLng(${botR[chosenPlate]!.latitude} ${botR[chosenPlate]!.longitude})");
  }

  ElevatedButton resetBtn(dynamic chartName) {
    return ElevatedButton(
      onPressed: () {
        dynamic tempChart = '$chartName.png';
        //setState(() {
        Provider.of<ProviderService>(context, listen: false).clearChar();
        Provider.of<ProviderService>(context, listen: false)
            .addRotatedOverLayImageX(tempChart);
      },
      child: const Text('Reset'),
    );
  }

  ElevatedButton printChartPos() {
    return ElevatedButton(
        onPressed: printChartPosition, child: const Text('Print'));
  }

  LatLng getCenterLatLng(
      LatLng topLeftCorner, LatLng bottomLeftCorner, LatLng bottomRightCorner) {
    double centerLatitude =
        (topLeftCorner.latitude + bottomRightCorner.latitude) / 2;
    double centerLongitude =
        (topLeftCorner.longitude + bottomRightCorner.longitude) / 2;
    return LatLng(centerLatitude, centerLongitude);
  }

  getOffsets(
      LatLng centerLatLng, LatLng topLeftCorner, LatLng bottomRightCorner) {
    double offsetLatTopLeft = centerLatLng.latitude - topLeftCorner.latitude;
    double offsetLngTopLeft = centerLatLng.longitude - topLeftCorner.longitude;
    double offsetLatTopRight = offsetLatTopLeft;
    double offsetLngTopRight =
        centerLatLng.longitude - bottomRightCorner.longitude;
    // print(
    //     "Offset of top left corner from center coordinate: ($offsetLatTopLeft, $offsetLngTopLeft)");
    // print(
    //    "Offset of top right corner from center coordinate: ($offsetLatTopRight, $offsetLngTopRight)");
  }

  void clear() {
    polyAirPlaneRoute.clear();
    Provider.of<MarkerListProvider>(context, listen: false).clear();
    // Provider.of<ProviderService>(context, listen: false).overlayImagesX.clear();
  }

  void procedure() {
    // RouteProcedureDialog(chipList: _chipList, clear: clear);
    var provider = Provider.of<MarkerListProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext conte) {
        return StatefulBuilder(builder: (contex, setState) {
          return RouteProcedureDialog(
            // chipList: provider.chipList,
            clear: clear,
            onClose: () {
              //  value.totalUserPolyline
              //                   .expand((element) => element)
              //                   .toList(),
              WidgetsBinding.instance.addPostFrameCallback((_) {});
              // customRoute;
              // provider.totalUserPolyline;
            },
          );
        });
      },
    );
  }

  void departure() {
    print('departure called');
    //customRoute.clear();
    var provider = Provider.of<MarkerListProvider>(context, listen: false);
  }

  void arrival() {
    var provider = Provider.of<MarkerListProvider>(context, listen: false);
    print('${provider.customMarker.length}');
    for (var i = 0; i < provider.customMarker.length; i++) {
      print('${provider.customMarker[i].key}');
    }
  }

  void setImage() {
    List<BaseOverlayImageX> images =
        Provider.of<ProviderService>(context, listen: false).overlayImagesX;
    Provider.of<ProviderService>(context, listen: false)
        .setOverlayImagesX(images);
  }

  //REMOVE THIS JUST FOR FAST LOADING CHART TO TEST
  void getImageSize(String chartName, BuildContext context) {
    final imageProvider = AssetImage('assets/$chartName');
    final imageStream = imageProvider.resolve(const ImageConfiguration());
    int width = 0;
    int height = 0;
    imageStream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      width = info.image.width;
      height = info.image.height;
      print('Overlay image width: $width, height: $height');
      calculateImageCorners(flutterMapController.center, width, height,
          flutterMapController.zoom + 3.14159265, chartName, context);
    }));
  }

  //void calculateImageCorners() {
  void calculateImageCorners(LatLng center, int imageWidth, int imageHeight,
      double mapZoom, dynamic chartName, BuildContext context) {
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
    // Provider.of<ProviderService>(context, listen: false)
    //     .addTestRotatedOverLayImageX(chartName, topC, botC, rightC);
    print('Top Left: $topLeftLatitude, $topLeftLongitude');
    print('Bottom Left: $bottomLeftLatitude, $bottomLeftLongitude');
    print('Bottom Right: $bottomRightLatitude, $bottomRightLongitude');
  }
}
