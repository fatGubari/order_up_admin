class Location {
  double latitude;
  double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
        latitude: map["latitude"], longitude: map["longitude"]);
  }

  @override
  String toString() {
    return '$latitude, $longitude';
  }

  toLowerCase() {}
}