/// Một thông báo trong `GET /api/alerts`.
class NotificationAlert {
  final int id;
  final String type;
  final String severity;
  final String message;
  final String status;
  final DateTime? createdAt;

  const NotificationAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.status,
    this.createdAt,
  });

  bool get isResolved => status == 'Resolved';

  NotificationAlert resolved() => NotificationAlert(
    id: id,
    type: type,
    severity: severity,
    message: message,
    status: 'Resolved',
    createdAt: createdAt,
  );

  factory NotificationAlert.fromJson(Map<String, dynamic> json) {
    return NotificationAlert(
      id: (json['id'] as num).toInt(),
      type: json['type']?.toString() ?? '',
      severity: json['severity']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      )?.toLocal(),
    );
  }
}
