import 'package:latlong2/latlong.dart';

class ChipModel {
  final String id;
  final String name;
  final LatLng? latLng;
  final List<LatLng>? listLatLng;
  final String type;

  ChipModel(
      {required this.id,
      required this.name,
      this.latLng,
      this.listLatLng,
      required this.type});
}
