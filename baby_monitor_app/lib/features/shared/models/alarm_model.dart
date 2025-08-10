import 'app_user.dart';
import 'room_model.dart';

enum AlarmStatus { inactive, active, acknowledged }

class Alarm {
  final int id;
  final int roomId;
  final int parentId;
  final AlarmStatus status;
  final DateTime triggeredAt;
  final DateTime? acknowledgedAt;
  final int? acknowledgedBy;
  final String? notes;

  // Related objects
  final Room? room;
  final AppUser? parent;
  final AppUser? acknowledgedByUser;

  const Alarm({
    required this.id,
    required this.roomId,
    required this.parentId,
    required this.status,
    required this.triggeredAt,
    this.acknowledgedAt,
    this.acknowledgedBy,
    this.notes,
    this.room,
    this.parent,
    this.acknowledgedByUser,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      roomId: json['room_id'],
      parentId: json['parent_id'],
      status: AlarmStatus.values.firstWhere(
        (e) => e.toString() == 'AlarmStatus.${json['status']}',
        orElse: () => AlarmStatus.inactive,
      ),
      triggeredAt: DateTime.parse(json['triggered_at']),
      acknowledgedAt: json['acknowledged_at'] != null
          ? DateTime.parse(json['acknowledged_at'])
          : null,
      acknowledgedBy: json['acknowledged_by'],
      notes: json['notes'],
      room: json['room'] != null ? Room.fromJson(json['room']) : null,
      parent: json['parent'] != null ? AppUser.fromJson(json['parent']) : null,
      acknowledgedByUser: json['acknowledged_by_user'] != null
          ? AppUser.fromJson(json['acknowledged_by_user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'parent_id': parentId,
      'status': status.name,
      'triggered_at': triggeredAt.toIso8601String(),
      'acknowledged_at': acknowledgedAt?.toIso8601String(),
      'acknowledged_by': acknowledgedBy,
      'notes': notes,
    };
  }

  Alarm copyWith({
    int? id,
    int? roomId,
    int? parentId,
    AlarmStatus? status,
    DateTime? triggeredAt,
    DateTime? acknowledgedAt,
    int? acknowledgedBy,
    String? notes,
    Room? room,
    AppUser? parent,
    AppUser? acknowledgedByUser,
  }) {
    return Alarm(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      parentId: parentId ?? this.parentId,
      status: status ?? this.status,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      notes: notes ?? this.notes,
      room: room ?? this.room,
      parent: parent ?? this.parent,
      acknowledgedByUser: acknowledgedByUser ?? this.acknowledgedByUser,
    );
  }

  bool get isActive => status == AlarmStatus.active;
  bool get isAcknowledged => status == AlarmStatus.acknowledged;
  bool get isInactive => status == AlarmStatus.inactive;

  String get statusDisplayName {
    switch (status) {
      case AlarmStatus.inactive:
        return 'Tidak Aktif';
      case AlarmStatus.active:
        return 'Alarm Aktif';
      case AlarmStatus.acknowledged:
        return 'Diterima';
    }
  }

  @override
  String toString() {
    return 'Alarm(id: $id, roomId: $roomId, status: $status)';
  }
}
