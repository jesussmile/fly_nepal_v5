class AllMarkers {
  final String code;
  final String? name;
  final double latitude;
  final double longitude;
  final double? elevation;

  AllMarkers({
    required this.code,
    this.name,
    required this.latitude,
    required this.longitude,
    this.elevation,
  });
}
