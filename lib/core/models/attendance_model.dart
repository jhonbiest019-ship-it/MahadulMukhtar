enum AttendanceStatus {
  present,
  absent,
  leave,
  late,
}

extension AttendanceStatusExtension on AttendanceStatus {
  String toUrduString() {
    switch (this) {
      case AttendanceStatus.present:
        return 'حاضر';
      case AttendanceStatus.absent:
        return 'غیر حاضر';
      case AttendanceStatus.leave:
        return 'رخصت';
      case AttendanceStatus.late:
        return 'تاخیر';
    }
  }

  static AttendanceStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'present':
      case 'حاضر':
        return AttendanceStatus.present;
      case 'absent':
      case 'غیر حاضر':
        return AttendanceStatus.absent;
      case 'leave':
      case 'رخصت':
        return AttendanceStatus.leave;
      case 'late':
      case 'تاخیر':
        return AttendanceStatus.late;
      default:
        return AttendanceStatus.present;
    }
  }
}

class AttendanceRecord {
  final String id;
  final String studentId;
  final String date; // YYYY-MM-DD format
  final AttendanceStatus status;
  final String remarks;
  final bool whatsappSent;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.date,
    required this.status,
    this.remarks = '',
    this.whatsappSent = false,
  });

  AttendanceRecord copyWith({
    String? id,
    String? studentId,
    String? date,
    AttendanceStatus? status,
    String? remarks,
    bool? whatsappSent,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      whatsappSent: whatsappSent ?? this.whatsappSent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date,
      'status': status.name,
      'remarks': remarks,
      'whatsappSent': whatsappSent,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      date: json['date'] as String,
      status: AttendanceStatusExtension.fromString(json['status'] as String),
      remarks: json['remarks'] as String? ?? '',
      whatsappSent: json['whatsappSent'] as bool? ?? false,
    );
  }
}
