class QueueItem {
  final String id;
  final String renterName;
  final DateTime queuedAt;
  final String? targetCarId;
  final String? targetCarName;

  QueueItem({
    required this.id,
    required this.renterName,
    required this.queuedAt,
    this.targetCarId,
    this.targetCarName,
  });

  factory QueueItem.fromJson(Map<String, dynamic> json) {
    return QueueItem(
      id: json['id'].toString(),
      renterName: json['renter_name'],
      queuedAt: DateTime.parse(json['queued_at']).toLocal(),
      targetCarId: json['target_car_id'],
      targetCarName: json['target_car_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'renter_name': renterName,
      'queued_at': queuedAt.toUtc().toIso8601String(),
      'target_car_id': targetCarId,
      'target_car_name': targetCarName,
    };
  }
}