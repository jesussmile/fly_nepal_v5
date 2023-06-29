import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:fly_nepal/modified_flutter_class/load_chart_btn.dart';
import 'package:latlong2/latlong.dart';

class PolylinePageTest extends StatefulWidget {
  static const String route = 'polyline';

  const PolylinePageTest({Key? key}) : super(key: key);

  @override
  State<PolylinePageTest> createState() => _PolylinePageTestState();
}

class _PolylinePageTestState extends State<PolylinePageTest> {
  List<LatLng> points = <LatLng>[];
  static double centerLat = 22.544743;
  static double centerLong = 113.964011;
  LatLng center = LatLng(22.544743, 113.964011);

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 573672; ++i) {
      // await Future.delayed(Duration.zero); // Allow time for UI to update
      // double x = centerLat + i * .00001;
      // double y = centerLat + i * .00001;
      // points.add(LatLng(x, y));
      points.add(LatLng(centerLat + i * .00001, centerLong + i * .00001));

      // addPointsAsync().then((_) {
      //   print('First Point: ${points.first}');
      //   print('Middle Point: ${points[points.length ~/ 2]}');
      //   print('Last Point: ${points.last}');
      // });
    }
  }

  Future<void> addPointsAsync() async {
    for (var i = 0; i < 573672; ++i) {
      // await Future.delayed(Duration.zero); // Allow time for UI to update
      double x = centerLat + i * .00001;
      double y = centerLat + i * .00001;
      points.add(LatLng(x, y));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Polylines')),
      //drawer: buildDrawer(context, PolylinePageTest.route),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: Text('Polylines'),
            ),
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  center: center,
                  zoom: 8,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: points,
                        strokeWidth: 4,
                        color: Colors.purple,
                      )
                    ],
                  ),
                  FlutterMapZoomButtonsX()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
