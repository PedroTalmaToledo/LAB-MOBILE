class Tracking {
  final String deliveryId;
  final String driverId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  Tracking({
    required this.deliveryId,
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory Tracking.fromJson(Map<String, dynamic> json) {
    return Tracking(
      deliveryId: json['deliveryId'],
      driverId: json['driverId'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveryId': deliveryId,
      'driverId': driverId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
