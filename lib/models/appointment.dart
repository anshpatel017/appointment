import 'package:uuid/uuid.dart';

class Appointment {
  final String id;
  final String name;
  final String serviceType;
  final String date; // YYYY-MM-DD
  final String timeSlot;
  final String status;
  final int queuePosition;
  final String createdAt;
  final bool isSynced;

  Appointment({
    String? id,
    required this.name,
    required this.serviceType,
    required this.date,
    required this.timeSlot,
    this.status = 'Scheduled',
    this.queuePosition = 0,
    String? createdAt,
    this.isSynced = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  /// Convert Appointment to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'service_type': serviceType,
      'date': date,
      'time_slot': timeSlot,
      'status': status,
      'queue_position': queuePosition,
      'created_at': createdAt,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  /// Create Appointment from SQLite Map
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as String,
      name: map['name'] as String,
      serviceType: map['service_type'] as String,
      date: map['date'] as String,
      timeSlot: map['time_slot'] as String,
      status: map['status'] as String,
      queuePosition: map['queue_position'] as int,
      createdAt: map['created_at'] as String,
      isSynced: (map['is_synced'] as int) == 1,
    );
  }

  /// Create a copy with modified fields
  Appointment copyWith({
    String? id,
    String? name,
    String? serviceType,
    String? date,
    String? timeSlot,
    String? status,
    int? queuePosition,
    String? createdAt,
    bool? isSynced,
  }) {
    return Appointment(
      id: id ?? this.id,
      name: name ?? this.name,
      serviceType: serviceType ?? this.serviceType,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      queuePosition: queuePosition ?? this.queuePosition,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  String toString() {
    return 'Appointment(id: $id, name: $name, service: $serviceType, '
        'date: $date, slot: $timeSlot, status: $status, '
        'queue: $queuePosition, synced: $isSynced)';
  }

  /// Short appointment ID for display (first 8 chars)
  String get shortId => id.substring(0, 8).toUpperCase();
}
