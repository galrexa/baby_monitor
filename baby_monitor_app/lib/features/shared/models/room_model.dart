import 'app_user.dart';

class Room {
  final int id;
  final String name;
  final String description;
  final int? parentId;
  final List<int> caretakerIds;
  final bool isActive;
  final String? customAlarmSound;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Related objects
  final AppUser? parent;
  final List<AppUser> caretakers;

  const Room({
    required this.id,
    required this.name,
    this.description = '',
    this.parentId,
    this.caretakerIds = const [],
    this.isActive = true,
    this.customAlarmSound,
    required this.createdAt,
    this.updatedAt,
    this.parent,
    this.caretakers = const [],
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      parentId: json['parent_id'],
      caretakerIds: json['caretaker_ids'] != null
          ? List<int>.from(json['caretaker_ids'])
          : [],
      isActive: json['is_active'] ?? true,
      customAlarmSound: json['custom_alarm_sound'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      parent: json['parent'] != null ? AppUser.fromJson(json['parent']) : null,
      caretakers: json['caretakers'] != null
          ? (json['caretakers'] as List)
              .map((item) => AppUser.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parent_id': parentId,
      'caretaker_ids': caretakerIds,
      'is_active': isActive,
      'custom_alarm_sound': customAlarmSound,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Room copyWith({
    int? id,
    String? name,
    String? description,
    int? parentId,
    List<int>? caretakerIds,
    bool? isActive,
    String? customAlarmSound,
    DateTime? createdAt,
    DateTime? updatedAt,
    AppUser? parent,
    List<AppUser>? caretakers,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      caretakerIds: caretakerIds ?? this.caretakerIds,
      isActive: isActive ?? this.isActive,
      customAlarmSound: customAlarmSound ?? this.customAlarmSound,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parent: parent ?? this.parent,
      caretakers: caretakers ?? this.caretakers,
    );
  }

  @override
  String toString() {
    return 'Room(id: $id, name: $name, parentId: $parentId, caretakers: ${caretakerIds.length})';
  }
}
