import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:fly_nepal/providers/MarkerListProvider.dart';
import 'package:fly_nepal/utils/cache_map.dart';
import 'package:fly_nepal/widgets/scale_plugin.dart';
import 'package:fly_nepal/services/data.dart';
import 'package:fly_nepal/modified_flutter_class/polyLineX.dart';
import 'package:fly_nepal/widgets/flutterMap_zoom_button.dart';
import 'package:fly_nepal/widgets/way_point.marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class RouteProcedureDialog extends StatefulWidget {
  final Function clear;
  final VoidCallback? onClose;
  const RouteProcedureDialog({super.key, required this.clear, this.onClose});
  @override
  State<RouteProcedureDialog> createState() => _RouteProcedureDialogState();
}

class _RouteProcedureDialogState extends State<RouteProcedureDialog> {
  List<LatLng> chipAppPoints = [];
  String _selectedData = '';
  List<LatLng> customSidRoute = [];
  final List<Marker> _markersSidTransition = [];
  final List<Marker> markerStar = [];
  final List<Marker> _approachFixes = [];
  final List<Marker> _markersSidTranFix = [];
  final List<Marker> _markersSidFix = [];
  //final List<Marker> _appTransFixes = [];
  String approach1 = '';
  List<Marker> _appTransFixesMarker = [];
  List<LatLng> customSidTransRoute = [];
  List<PolylineX> delAppTransPoly = [];
  List<Marker> apprTransMarker = [];
  List<Star> _stars = [];
  List<Approach> _approach = [];
  List<List<Marker>> appMarkerSegment = [];
  List<Sid> _sids = [];
  List<PolylineX> tempPolylines = [];
  final List<PolylineX> _sidFixesPolylines = [];
  final List<PolylineX> _sidTransitionFixesPolylines = [];
  final List<PolylineX> _starPolylines = [];
  final List<PolylineX> _appFixesPolylines = [];
  List<PolylineX> _appTransPolylines = [];
  final List<PolylineX> testPoly = [];
  final List<PolylineX> _approachTransFixes = [];
  List<LatLng> sidFixCopy = [];
  List<Fix> _fix = [];
  List<Marker> removedMarkers = [];
  List<PolylineX> removedPolylines = [];
  List<PolylineX> removedAppFixPolylines = [];
  late PolylineX selectedPolyline;
  final _mapKeyProc = GlobalKey<FlutterMapState>();
  int _transitionLength = 0;
  final List<String> _transitionName = [];
  String chipSidTrans = "";
  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   widget.onClose?.call();
  //   super.didChangeDependencies();
  // }
  @override
  void dispose() {
    widget.onClose?.call();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    var provider = Provider.of<MarkerListProvider>(context, listen: false);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.08,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                    title: const Text('SID'),
                    selected: _selectedData == 'sid', // Check if it is selected

                    selectedTileColor: const Color.fromARGB(255, 139, 242, 87),
                    onTap: () {
                      provider.chipList.isNotEmpty
                          ? loadData(provider.chipList[0].name).then((_) {
                              setState(() {
                                _transitionLength = 0;
                                _selectedData = 'sid';
                              });
                              // handle departure item tap
                            })
                          : null;
                    }),
                ListTile(
                  title: const Text('STAR'),
                  selectedTileColor: const Color.fromARGB(255, 139, 242, 87),
                  onTap: () {
                    _transitionLength = 0;
                    provider.chipList.isNotEmpty
                        ? loadData(provider.chipList.last.name).then((_) {
                            setState(() {
                              _transitionLength = 0;
                              _selectedData = 'star';
                            });
                            // handle departure item tap
                          })
                        : null;
                    // handle departure item tap
                  },
                ),
                ListTile(
                  title: const Text('APP'),
                  selectedTileColor: const Color.fromARGB(255, 139, 242, 87),
                  onTap: () {
                    provider.chipList.isNotEmpty
                        ? loadData(provider.chipList.last.name).then((_) {
                            setState(() {
                              _transitionLength = 0;
                              _selectedData = 'approach';
                            });
                            // handle departure item tap
                          })
                        : null;
                  },
                ),
                ListTile(
                  title: const Text('CLEAR'),
                  onTap: () {
                    setState(() {
                      _appTransFixesMarker.clear();
                      _appFixesPolylines.clear();
                      _approachFixes.clear();
                      _approach.clear();
                      _approachFixes.clear();
                      // _appTransFixes.clear();
                      markerStar.clear();
                      _markersSidTranFix.clear();
                      _markersSidTransition.clear();
                      _sidFixesPolylines.clear();
                      _sidTransitionFixesPolylines.clear();
                      _sids.clear();
                      _starPolylines.clear();
                      _stars.clear();
                      _transitionLength = 0;
                      _transitionName.clear();
                      _markersSidFix.clear();
                      _appTransPolylines.clear();
                      _approachTransFixes.clear();
                      apprTransMarker.clear();
                    });
                    // handle holding item tap
                  },
                ),
              ],
            ),
          ),
          Container(
            width: width * 0.1,
            color: Colors.grey,
            child: ListView.builder(
              itemCount: _selectedData == 'sid'
                  ? _sids.length
                  : _selectedData == 'star'
                      ? _stars.length
                      : _approach.length,
              itemBuilder: (BuildContext context, int index) {
                if (_selectedData == 'sid') {
                  List<LatLng> points = [];
                  List<LatLng> segment = [];
                  final sid = _sids[index];
                  return ListTile(
                    title: Text(sid.name),
                    subtitle: Text('RNW ${sid.rnw}'),
                    onTap: () {
                      List<String> pointName = [];
                      _transitionName.clear();
                      _markersSidTranFix.clear();
                      _markersSidTransition.clear();
                      removedMarkers.clear();
                      removedPolylines.clear();
                      _transitionLength = sid.transitions.length;
                      _sidFixesPolylines.clear();
                      _markersSidFix.clear();
                      _sidTransitionFixesPolylines.clear();
                      points = [provider.chipList[0].latLng!];
                      sid.fixes.forEach((key, value) {
                        for (var element in _fix) {
                          if (key == element.name) {
                            points.add(LatLng(element.lat, element.lon));
                            pointName.add(element.name);
                            setState(
                              () {
                                _sidFixesPolylines.add(PolylineX(
                                    points: points,
                                    isDotted: false,
                                    strokeWidth: 3,
                                    borderColor: Colors.black.withOpacity(0.5),
                                    borderStrokeWidth: 2,
                                    color:
                                        const Color.fromARGB(255, 3, 227, 248)
                                            .withOpacity(0.5)));

                                _markersSidFix.add(Marker(
                                  anchorPos: AnchorPos.align(AnchorAlign.right),
                                  width: 57,
                                  height: 16,
                                  point: LatLng(points.last.latitude,
                                      points.last.longitude),
                                  builder: (ctx) =>
                                      WayPointMarkerTap(str: element.name),
                                ));
                              },
                            );
                          }
                        }
                      });
                      //print(sid.name);
                      chipSidTrans = sid.name; //first part Darke1D.Naran
                      sidFixCopy = List<LatLng>.from(points);
                      sidFixCopy.removeAt(
                          0); //remove the fist item as its not required for the main route

                      _markersSidTransition.add(Marker(
                        anchorPos: AnchorPos.align(AnchorAlign.right),
                        width: 57,
                        height: 16,
                        point:
                            LatLng(points.last.latitude, points.last.longitude),
                        builder: (ctx) =>
                            WayPointMarkerTap(str: pointName.last),
                      ));

                      provider.loadCustomMarker(points.last.latitude,
                          points.last.longitude, pointName.last);
                      //print(sid.transitions.length);
                      for (final transition in sid.transitions) {
                        //print(transition.name);
                        _transitionName.add(transition.name);
                        for (var element in _fix) {
                          if (transition.name == element.name) {
                            _markersSidTranFix.add(Marker(
                              anchorPos: AnchorPos.align(AnchorAlign.right),
                              width: 57,
                              height: 16,
                              key: ValueKey<String>(element.name),
                              point: LatLng(element.lat, element.lon),
                              builder: (ctx) =>
                                  WayPointMarkerTap(str: element.name),
                            ));
                            provider.loadCustomMarker(
                                element.lat, element.lon, element.name);
                          }
                        }
                        segment = [
                          LatLng(points.last.latitude, points.last.longitude)
                        ];
                        for (final fixTransition in transition.fixes) {
                          for (var element in _fix) {
                            if (fixTransition == element.name) {
                              segment.add(LatLng(element.lat, element.lon));
                            }
                          }
                        }
                        setState(
                          () {
                            _sidTransitionFixesPolylines.add(
                              PolylineX(
                                points: segment,
                                isDotted: false,
                                strokeWidth: 3,
                                borderColor: Colors.black.withOpacity(0.5),
                                borderStrokeWidth: 2,
                                color: const Color.fromARGB(255, 243, 150, 10)
                                    .withOpacity(0.7),
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                } else if (_selectedData == "star") {
                  List<LatLng> points = [];
                  //List<LatLng> segment = [];
                  final star = _stars[index];
                  return ListTile(
                    title: Text(star.name),
                    subtitle: Text(star.runway),
                    onTap: () {
                      _transitionName.clear();
                      markerStar.clear();
                      _starPolylines.clear();
                      //points = [widget.chipList.last.latLng];
                      star.fixes.forEach((key, value) {
                        for (var element in _fix) {
                          if (key == element.name) {
                            // print(element.name);
                            points.add(LatLng(element.lat, element.lon));
                            setState(
                              () {
                                _starPolylines.add(PolylineX(
                                    points: points,
                                    isDotted: false,
                                    strokeWidth: 3,
                                    borderColor: Colors.black.withOpacity(0.5),
                                    borderStrokeWidth: 2,
                                    color:
                                        const Color.fromARGB(255, 3, 227, 248)
                                            .withOpacity(0.5)));
                              },
                            );

                            markerStar.add(Marker(
                              anchorPos: AnchorPos.align(AnchorAlign.right),
                              width: 57,
                              height: 16,
                              point: LatLng(element.lat, element.lon),
                              builder: (ctx) =>
                                  WayPointMarkerTap(str: element.name),
                            ));
                            provider.loadCustomMarker(
                                element.lat, element.lon, element.name);
                          }
                        }
                      });
                      List<LatLng> starP = [];
                      starP = _starPolylines
                          .expand((element) => element.points)
                          .toList();

                      provider.addChips(
                          DateTime.now().toString(),
                          star.name,
                          listLatLng: starP,
                          // latLng: LatLng(element.lat, element.lon),
                          'star');

                      provider.addStar(
                          points); //code from here this gets aded to totaluserlatlng points so go around starts from here fix it
                    },
                  );
                } else if (_selectedData == 'approach') {
                  final approach = _approach[index];
                  List<LatLng> points = [];
                  List<LatLng> point1 = [];
                  List<LatLng> point2 = [];
                  List<List<LatLng>> segments =
                      []; // new list to store segments separately
                  List<LatLng> segment = [];
                  List<String> name = [];
                  return ListTile(
                    title: Text(approach.name),
                    subtitle: Text(
                        'RNW ${approach.name.substring(approach.name.length - 2)}'),
                    onTap: () {
                      bool first = false;
                      bool markerF = false;
                      bool goaround = false;
                      setState(() {
                        _transitionName.clear();
                        _approachFixes.clear();
                        _appFixesPolylines.clear();
                        _appTransFixesMarker.clear();
                        _appTransPolylines.clear();
                        _approachTransFixes.clear();
                        removedMarkers.clear();
                        removedPolylines.clear();
                        _transitionLength = approach.transitions.length;
                        _appFixesPolylines.clear();
                        tempPolylines.clear();
                        apprTransMarker.clear();
                        appMarkerSegment.clear();
                      });
                      Color polylineColor;
                      approach.fixes.forEach((key, value) {
                        for (var element in _fix) {
                          if (key == element.name) {
                            //print(element.name);
                            if (value.contains("RNW ") && first == false) {
                              //example RNAV28
                              //this poiNt is just before AIRPORT after this is go around
                              //vnbw -BW101 is added here
                              points.add(LatLng(
                                  element.lat, element.lon)); //BASUB +BW101
                              //BASUB +BW101 +VNBW

                              for (int i = provider.chipList.length - 1;
                                  i >= 0;
                                  i--) {
                                //add the point to airport
                                if (provider.allAirports
                                    .contains(provider.chipList[i].name)) {
                                  points.add(provider.chipList[i].latLng!);
                                  break;
                                }
                              }

                              //SAME AS ABOVE ONLY THAT THIS PLOTS POLYLINE
                              point1.add(LatLng(element.lat, element.lon));
                              for (int i = provider.chipList.length - 1;
                                  i >= 0;
                                  i--) {
                                if (provider.allAirports
                                    .contains(provider.chipList[i].name)) {
                                  point1.add(provider.chipList[i].latLng!);
                                  break;
                                }
                              }

                              polylineColor =
                                  const Color.fromARGB(255, 82, 171, 244);
                              setState(
                                () {
                                  _appFixesPolylines.add(PolylineX(
                                      points: point1,
                                      isDotted: false,
                                      strokeWidth: 5,
                                      borderColor:
                                          Colors.black.withOpacity(0.3),
                                      borderStrokeWidth: 2,
                                      color: polylineColor.withOpacity(0.7)));
                                  // const Color.fromARGB(255, 3, 227, 248)
                                  //     .withOpacity(0.5)));
                                },
                              );
                              first = true;
                            } else if (first == true) {
                              //go around also might contain some RWY  value so the logic is below
                              polylineColor =
                                  const Color.fromARGB(255, 243, 11, 220);
                              points.add(LatLng(element.lat, element.lon));
                              point2.add(LatLng(element.lat, element.lon));
                              if (goaround == false) {
                                //only connect one point to the airport of goaround else all goaround points get connected
                                for (int i = provider.chipList.length - 1;
                                    i >= 0;
                                    i--) {
                                  if (provider.allAirports
                                      .contains(provider.chipList[i].name)) {
                                    point2.add(provider.chipList[i].latLng!);
                                    goaround = true;
                                    break;
                                  }
                                }
                              }
                              setState(
                                () {
                                  _appFixesPolylines.add(PolylineX(
                                      points: point2,
                                      isDotted: true,
                                      strokeWidth: 5,
                                      borderColor:
                                          Colors.black.withOpacity(0.5),
                                      borderStrokeWidth: 2,
                                      color: polylineColor));
                                  // const Color.fromARGB(255, 3, 227, 248)
                                  //     .withOpacity(0.5)));
                                },
                              );
                              chipAppPoints.addAll(point1);
                              //chipAppPoints.addAll(point2);
                              provider.addAppFix(point1); //basub bw101
                              //provider.addAppFix(point2); //go aroud makab
                              // print(point2);
                            } else {
                              //here, the value is before ay RNW
                              //ex VNBW -BASUB is added here
                              points.add(LatLng(element.lat, element.lon));
                              point1.add(LatLng(element.lat, element.lon));
                            }
                            //after adding lat lng to different points

                            if (value.contains("RNW ") && markerF == false) {
                              //print(value);
                              LatLng? destAptPoint;
                              String? destAirport;
                              setState(() {
                                _approachFixes.add(Marker(
                                  //key: ValueKey(provider.chipList.last.name),
                                  anchorPos: AnchorPos.align(AnchorAlign.right),
                                  width: 57,
                                  height: 16,
                                  point: LatLng(element.lat, element.lon),
                                  builder: (ctx) {
                                    return WayPointMarkerTap(str: element.name);
                                  },
                                ));
                                provider.loadCustomMarker(
                                    element.lat, element.lon, element.name);
                                // print("contains RNW ${element.name}");
                                for (int i = provider.chipList.length - 1;
                                    i >= 0;
                                    i--) {
                                  if (provider.allAirports
                                      .contains(provider.chipList[i].name)) {
                                    // point2.add(provider.chipList[i].latLng!);
                                    destAirport = provider.chipList[i].name;
                                    destAptPoint = provider.chipList[i].latLng!;
                                    break;
                                  }
                                }
                                _approachFixes.add(Marker(
                                  //key: ValueKey(provider.chipList.last.name),
                                  anchorPos: AnchorPos.align(AnchorAlign.right),
                                  width: 57,
                                  height: 16,
                                  point:
                                      destAptPoint!, //LatLng(element.lat, element.lon),

                                  builder: (ctx) => WayPointMarkerTap(
                                      str: destAirport!), //VNBW
                                ));
                                // provider.loadCustomMarker(, longitude, identifier)
                              });
                              // print(
                              //     "contains RNW ${provider.chipList.last.name}");
                              markerF = true;
                            } else {
                              //for VNBW BASUB IS ADDED HERE
                              setState(() {
                                _approachFixes.add(Marker(
                                  key: ValueKey(element.name),
                                  anchorPos: AnchorPos.align(AnchorAlign.right),
                                  width: 57,
                                  height: 16,
                                  point: LatLng(element.lat, element.lon),
                                  builder: (ctx) {
                                    //
                                    return WayPointMarkerTap(str: element.name);
                                  },
                                ));
                                provider.loadCustomMarker(
                                    element.lat, element.lon, element.name);
                              });
                              // print("below contains RNW ${element.name}");
                            }
                          }
                        }
                      });
                      provider.addGoAround(point2);
                      //makpa and repox in vnbw
                      for (final fixTransition in approach.transitions) {
                        _transitionName.add(fixTransition.name);
                        segment = [];
                        _appTransFixesMarker = [];
                        name = [];
                        int i = 0;
                        fixTransition.fixes.forEach((key, value) {
                          for (var element in _fix) {
                            if (key == element.name) {
                              name.add(element.name);
                              i++;
                              segment.add(LatLng(element.lat, element.lon));
                              _appTransFixesMarker.add(Marker(
                                anchorPos: AnchorPos.align(AnchorAlign.right),
                                key: ValueKey<String>(
                                    element.name + i.toString()),
                                width: 57,
                                height: 16,
                                point: LatLng(element.lat, element.lon),
                                builder: (ctx) =>
                                    WayPointMarkerTap(str: element.name),
                              ));
                              //print(element.name);
                              // provider.loadCustomMarker(
                              //     element.lat, element.lon, element.name);
                            }
                          }
                        });
                        segment.add(LatLng(
                            points.first.latitude, points.first.longitude));
                        segments.add(segment);
                        appMarkerSegment.add(_appTransFixesMarker);
                        setState(() {
                          apprTransMarker = appMarkerSegment
                              .expand((segment) => segment)
                              .toList();
                        });
                      }
                      for (var i = 0; i < segments.length; i++) {
                        setState(
                          () {
                            _appTransPolylines.add(PolylineX(
                                points: segments[i],
                                isDotted: false,
                                strokeWidth: 3,
                                borderColor: Colors.black.withOpacity(0.5),
                                borderStrokeWidth: 2,
                                color: const Color.fromARGB(255, 243, 150, 10)
                                    .withOpacity(0.7)));
                          },
                        );
                        // Provider.of<MarkerListProvider>(context, listen: false)
                        //     .totalCustomRoute(segments[i]);
                      }
                      tempPolylines = List.from(_appTransPolylines);
                      approach1 = approach.name;
                    },
                  );
                }
                return null;
              },
            ),
          ),
          Container(
            width: width * 0.1,
            color: Colors.blueAccent,
            child: ListView.builder(
              itemCount: _transitionLength,
              itemBuilder: (BuildContext context, int index) {
                final trans =
                    _transitionLength == 0 ? "" : _transitionName[index];
                return ListTile(
                  title: Text(trans),
                  onTap: () {
                    // print(trans);
                    if (_selectedData == 'sid') {
                      _markersSidTranFix.addAll(removedMarkers);
                      _sidTransitionFixesPolylines.addAll(removedPolylines);
                      customSidTransRoute.clear();
                      customSidRoute.clear();

                      removedMarkers = [];
                      removedPolylines = [];
                      for (var i = _markersSidTranFix.length - 1; i >= 0; i--) {
                        final keyString = _markersSidTranFix[i].key.toString();
                        final keyValue =
                            keyString.substring(3, keyString.length - 3);
                        if (keyValue != trans) {
                          removedMarkers.add(_markersSidTranFix[i]);
                          removedPolylines.add(_sidTransitionFixesPolylines[i]);
                          setState(() {
                            _markersSidTranFix.removeAt(i);
                            _sidTransitionFixesPolylines.removeAt(i);
                          });
                        }
                      }
                      customSidRoute.removeWhere(
                          (point) => customSidTransRoute.contains(point));
                      customSidTransRoute.addAll(_sidTransitionFixesPolylines
                          .first.points); //CHECK IF NECESSARY
                      customSidRoute.addAll(customSidTransRoute);
                      List<LatLng> copycustomSidRoute = List.from(
                          customSidRoute); //remove an extra duplicate latlng
                      copycustomSidRoute.removeAt(0);
                      provider.addSidFix(
                          sidFixCopy); //some time the user wont add transition so make sure it gets added only when transition is selected
                      provider.addSidFixTrans(copycustomSidRoute);
                      chipSidTrans = "$chipSidTrans.$trans";
                      provider.addChips(
                          DateTime.now().toString(),
                          chipSidTrans,
                          listLatLng: customSidTransRoute,
                          'sid');
                    } else if (_selectedData == 'star') {
                    } else if (_selectedData == 'approach') {
                      List<Marker> selectedMarkers =
                          List.from(appMarkerSegment[index]);
                      _appTransPolylines
                          .clear(); // Create a temporary copy of _appTransPolylines
                      _appTransPolylines = List.from(tempPolylines);
                      for (var i = 0; i < _appTransPolylines.length; i++) {
                        if (i == index) {
                          selectedPolyline = (_appTransPolylines[i]);
                        }
                      }
                      _appTransPolylines.clear();
                      _appTransPolylines.add(selectedPolyline);

                      for (PolylineX pol in _appTransPolylines) {
                        provider.addAppFixTrans(pol.points);
                        chipAppPoints.addAll(pol.points);
                      }

                      setState(() {
                        apprTransMarker = selectedMarkers;
                      });
                      provider.addChips(DateTime.now().toString(),
                          "$trans $approach1", 'approach',
                          listLatLng: chipAppPoints);

                      // for (var i = 0; i < apprTransMarker.length; i++) {
                      provider.customMarker.addAll(apprTransMarker);
                      //  }
                      // Provider.of<MarkerListProvider>(context, listen: false)
                      //     .loadCustomMarker(
                      //         selectedMarkers.first.point.latitude,
                      //         selectedMarkers.first.point.longitude,
                      //         selectedMarkers.first.key
                      //             .toString()
                      //             .substring(3, 8));
                    }
                  },
                );
              },
            ),
          ),
          Container(
            width: width * 0.5,
            color: Colors.red,
            child: FlutterMap(
              key: _mapKeyProc,
              options: MapOptions(
                  onTap: (tapPosition, point) {
                    print(point);
                  },
                  //center: LatLng(27.431769, 83.443274), //bwa
                  center: LatLng(27.808479, 85.407352), //ktm
                  zoom: 9,
                  minZoom: 6,
                  interactiveFlags: // InteractiveFlag.all),
                      InteractiveFlag.pinchZoom | InteractiveFlag.drag),
              nonRotatedChildren: [
                // ignore: prefer_const_constructors
                LoadChart(
                  minZoom: 4,
                  maxZoom: 19,
                  mini: true,
                  padding: 10,
                  alignment: Alignment.bottomRight,
                ),
                ScaleLayerWidget(
                    options: ScaleLayerPluginOption(
                        lineColor: Colors.white,
                        lineWidth: 2,
                        textStyle:
                            const TextStyle(color: Colors.white, fontSize: 12),
                        padding: const EdgeInsets.only(top: 30))),
              ],
              children: [
                TileLayer(
                  // tileProvider: CachedTileProvider(),
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoicGFubmFtIiwiYSI6ImNsZXBjbHZhcDAxa2szem1vZHg2ZHdzMTgifQ.ZwzH7NOdjAJwf15LlAZUGQ',
                  // ignore: prefer_const_literals_to_create_immutables
                  additionalOptions: {'id': 'mapbox/dark-v11'},
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayerX(
                  polylines: _sidFixesPolylines,
                ),
                PolylineLayerX(
                  polylines: _sidTransitionFixesPolylines,
                ),
                PolylineLayerX(
                  polylines: _starPolylines,
                ),
                PolylineLayerX(
                  polylines: _appTransPolylines,
                ),
                PolylineLayerX(
                  polylines: _appFixesPolylines,
                ),
                MarkerLayer(
                  markers: _markersSidFix,
                ),
                MarkerLayer(
                  markers: _markersSidTranFix,
                ),
                MarkerLayer(
                  markers: markerStar,
                ),
                MarkerLayer(
                  markers: _approachFixes,
                ),
                MarkerLayer(
                  markers: apprTransMarker,
                ),
              ],
            ),
            // add your content here
          ),
        ],
      ),
    );
  }

  Future<void> loadData(String airportProc) async {
    _checkAirport(airportProc, (bool exists) async {
      if (exists) {
        String jsonString = await DefaultAssetBundle.of(context)
            .loadString('assets/procJson/$airportProc.json');
        Map<String, dynamic> json = jsonDecode(jsonString);
        Data data = Data.fromJson(json);
        setState(() {
          _fix = data.fixes;
          _sids = data.sids;
          _stars = data.stars;
          _approach = data.approaches;
        });
        somethingWithFix();
      }
    });
  }

  Future<void> _checkAirport(String airportID, Function(bool) callback) async {
    bool airportExists = Provider.of<MarkerListProvider>(context, listen: false)
        .allAirports
        .contains(airportID);
    callback(airportExists);
  }

  void somethingWithFix() {
    var provider = Provider.of<MarkerListProvider>(context, listen: false);
    provider.fix.clear();
    provider.addFix(_fix);
  }
}
