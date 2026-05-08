class AuditModel {
  final String id;
  final String action;
  final String userName;
  final String? statusColor;
  final DateTime createdAt;

  AuditModel({
    required this.id,
    required this.action,
    required this.userName,
    this.statusColor,
    required this.createdAt,
  });

  factory AuditModel.fromJson(Map<String, dynamic> json) {
    return AuditModel(
      id: json['id'] ?? '',
      action: json['action'] ?? '',
      userName: json['user_name'] ?? 'System',
      statusColor: json['status_color'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'user_name': userName,
      'status_color': statusColor,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
