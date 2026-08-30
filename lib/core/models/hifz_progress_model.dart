class HifzProgressRecord {
  final String id;
  final String studentId;
  final String date; // YYYY-MM-DD
  final String sabaq; // Today's lesson
  final String sabqi; // Recent revision
  final String manzil; // Previous revision
  final String mistakes; // Mistakes & hesitations count/notes
  final String quality; // ممتاز (Excellent), عمدہ (Good), مناسب (Average), توجہ طلب (Needs improvement)
  final String teacherRemarks;

  String get qualityGrade => quality;

  HifzProgressRecord({
    required this.id,
    required this.studentId,
    required this.date,
    required this.sabaq,
    required this.sabqi,
    required this.manzil,
    this.mistakes = '0 غلطیاں',
    this.quality = 'ممتاز',
    this.teacherRemarks = '',
  });

  HifzProgressRecord copyWith({
    String? id,
    String? studentId,
    String? date,
    String? sabaq,
    String? sabqi,
    String? manzil,
    String? mistakes,
    String? quality,
    String? teacherRemarks,
  }) {
    return HifzProgressRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      sabaq: sabaq ?? this.sabaq,
      sabqi: sabqi ?? this.sabqi,
      manzil: manzil ?? this.manzil,
      mistakes: mistakes ?? this.mistakes,
      quality: quality ?? this.quality,
      teacherRemarks: teacherRemarks ?? this.teacherRemarks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date,
      'sabaq': sabaq,
      'sabqi': sabqi,
      'manzil': manzil,
      'mistakes': mistakes,
      'quality': quality,
      'teacherRemarks': teacherRemarks,
    };
  }

  factory HifzProgressRecord.fromJson(Map<String, dynamic> json) {
    return HifzProgressRecord(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      date: json['date'] as String,
      sabaq: json['sabaq'] as String,
      sabqi: json['sabqi'] as String,
      manzil: json['manzil'] as String,
      mistakes: json['mistakes'] as String? ?? '0 غلطیاں',
      quality: json['quality'] as String? ?? 'ممتاز',
      teacherRemarks: json['teacherRemarks'] as String? ?? '',
    );
  }
}

typedef HifzProgressModel = HifzProgressRecord;
