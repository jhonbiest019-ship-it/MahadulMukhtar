class StudentModel {
  int rollNo;
  String name;
  String fatherName;
  String currentPara;
  String daurStatus;
  String phoneNumber;
  bool feePaid;
  bool feePaidThisMonth;
  String status; // 'P', 'A', 'L', 'T'
  bool isSuspended;

  int get id => rollNo;
  String get whatsappNumber => phoneNumber;

  StudentModel({
    required this.rollNo,
    required this.name,
    required this.fatherName,
    required this.currentPara,
    this.daurStatus = 'دؤر 1',
    required this.phoneNumber,
    this.feePaid = false,
    this.feePaidThisMonth = true,
    this.status = 'P',
    this.isSuspended = false,
    dynamic id,
  });

  StudentModel copyWith({
    int? rollNo,
    String? name,
    String? fatherName,
    String? currentPara,
    String? daurStatus,
    String? phoneNumber,
    bool? feePaid,
    bool? feePaidThisMonth,
    String? status,
    bool? isSuspended,
  }) {
    return StudentModel(
      rollNo: rollNo ?? this.rollNo,
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      currentPara: currentPara ?? this.currentPara,
      daurStatus: daurStatus ?? this.daurStatus,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      feePaid: feePaid ?? this.feePaid,
      feePaidThisMonth: feePaidThisMonth ?? this.feePaidThisMonth,
      status: status ?? this.status,
      isSuspended: isSuspended ?? this.isSuspended,
    );
  }

  Map<String, dynamic> toJson() => {
    'rollNo': rollNo,
    'name': name,
    'fatherName': fatherName,
    'currentPara': currentPara,
    'daurStatus': daurStatus,
    'phoneNumber': phoneNumber,
    'feePaid': feePaid,
    'feePaidThisMonth': feePaidThisMonth,
    'status': status,
    'isSuspended': isSuspended,
  };

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    rollNo: json['rollNo'],
    name: json['name'],
    fatherName: json['fatherName'],
    currentPara: json['currentPara'],
    daurStatus: json['daurStatus'] ?? 'دؤر 1',
    phoneNumber: json['phoneNumber'] ?? '',
    feePaid: json['feePaid'] ?? false,
    feePaidThisMonth: json['feePaidThisMonth'] ?? true,
    status: json['status'] ?? 'P',
    isSuspended: json['isSuspended'] ?? false,
  );
}
