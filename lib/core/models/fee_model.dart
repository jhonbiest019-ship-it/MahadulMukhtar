class FeeRecord {
  final String id;
  final String studentId;
  final String month; // e.g. "August 2026"
  final double amount;
  final bool isPaid;
  final String paymentDate;

  FeeRecord({
    required this.id,
    required this.studentId,
    required this.month,
    required this.amount,
    required this.isPaid,
    this.paymentDate = '',
  });

  FeeRecord copyWith({
    String? id,
    String? studentId,
    String? month,
    double? amount,
    bool? isPaid,
    String? paymentDate,
  }) {
    return FeeRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'month': month,
      'amount': amount,
      'isPaid': isPaid,
      'paymentDate': paymentDate,
    };
  }

  factory FeeRecord.fromJson(Map<String, dynamic> json) {
    return FeeRecord(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      month: json['month'] as String,
      amount: (json['amount'] as num).toDouble(),
      isPaid: json['isPaid'] as bool? ?? false,
      paymentDate: json['paymentDate'] as String? ?? '',
    );
  }
}
