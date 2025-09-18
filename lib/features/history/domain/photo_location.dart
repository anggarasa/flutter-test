class PhotoLocation {
  final String id;
  final String photoPath;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;

  const PhotoLocation({
    required this.id,
    required this.photoPath,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photo_path': photoPath,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PhotoLocation.fromMap(Map<String, dynamic> map) {
    return PhotoLocation(
      id: map['id'] as String,
      photoPath: map['photo_path'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
