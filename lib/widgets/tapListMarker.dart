import 'package:flutter/material.dart';
import 'package:fly_nepal/model/TapMarkers.dart';

class MarkerListWidget extends StatelessWidget {
  final List<TapMarkers> markers;

  const MarkerListWidget(this.markers, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${markers.length} nearby markers'),
      ),
      body: ListView.builder(
        itemCount: markers.length,
        itemBuilder: (context, index) {
          final marker = markers[index];
          return ListTile(
            title: Text(marker.name ?? marker.code),
            subtitle: Text(
                ' ${marker.code}   ${marker.latitude}, ${marker.longitude}'),
          );
        },
      ),
    );
  }
}
