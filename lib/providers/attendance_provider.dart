import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/models/attendance_model.dart';
import '../core/models/student_model.dart';
import '../core/services/storage_service.dart';
import '../core/services/seeder_service.dart';
import '../core/services/firebase_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<AttendanceRecord> _records = [];
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  AttendanceProvider(this._storageService) {
    loadAttendance();
  }

  String get selectedDate => _selectedDate;

  List<AttendanceRecord> get allRecords => _records;

  List<AttendanceRecord> get todayRecords =>
      _records.where((r) => r.date == _selectedDate).toList();

  void setSelectedDate(String date, List<StudentModel> students) {
    _selectedDate = date;
    ensureDateRecordsExist(students);
    notifyListeners();
  }

  Future<void> loadAttendance() async {
    _records = _storageService.getAttendance();
    notifyListeners();
  }

  void ensureDateRecordsExist(List<StudentModel> students) {
    final existingForDate = todayRecords;
    if (existingForDate.isEmpty && students.isNotEmpty) {
      final initial = SeederService.getInitialAttendance(students, _selectedDate);
      _records.addAll(initial);
      _storageService.saveAttendance(_records);
    }
  }

  AttendanceStatus getStudentStatus(dynamic studentId) {
    final sId = studentId.toString();
    final rec = _records.firstWhere(
      (r) => r.studentId == sId && r.date == _selectedDate,
      orElse: () => AttendanceRecord(
        id: 'att_${sId}_$_selectedDate',
        studentId: sId,
        date: _selectedDate,
        status: AttendanceStatus.present,
      ),
    );
    return rec.status;
  }

  Future<void> updateStatus(dynamic studentId, AttendanceStatus newStatus) async {
    final sId = studentId.toString();
    final index = _records.indexWhere(
      (r) => r.studentId == sId && r.date == _selectedDate,
    );
    if (index != -1) {
      _records[index] = _records[index].copyWith(status: newStatus);
    } else {
      _records.add(
        AttendanceRecord(
          id: 'att_${sId}_$_selectedDate',
          studentId: sId,
          date: _selectedDate,
          status: newStatus,
        ),
      );
    }
    await _storageService.saveAttendance(_records);
    
    // Real-time Cloud Sync
    FirebaseCloudSyncService().syncAttendanceToCloud(
      date: _selectedDate,
      studentRoll: int.tryParse(sId) ?? 1,
      status: newStatus.name,
    );

    notifyListeners();
  }

  Future<void> markAllPresent(List<StudentModel> students) async {
    for (final std in students) {
      final sId = std.id.toString();
      final index = _records.indexWhere(
        (r) => r.studentId == sId && r.date == _selectedDate,
      );
      if (index != -1) {
        _records[index] = _records[index].copyWith(status: AttendanceStatus.present);
      } else {
        _records.add(
          AttendanceRecord(
            id: 'att_${sId}_$_selectedDate',
            studentId: sId,
            date: _selectedDate,
            status: AttendanceStatus.present,
          ),
        );
      }
      FirebaseCloudSyncService().syncAttendanceToCloud(
        date: _selectedDate,
        studentRoll: std.rollNo,
        status: 'present',
      );
    }
    await _storageService.saveAttendance(_records);
    notifyListeners();
  }

  Future<void> markWhatsAppSent(dynamic studentId) async {
    final sId = studentId.toString();
    final index = _records.indexWhere(
      (r) => r.studentId == sId && r.date == _selectedDate,
    );
    if (index != -1) {
      _records[index] = _records[index].copyWith(whatsappSent: true);
      await _storageService.saveAttendance(_records);
      notifyListeners();
    }
  }

  // STATISTICS COMPUTATION
  int get presentCount =>
      todayRecords.where((r) => r.status == AttendanceStatus.present).length;

  int get absentCount =>
      todayRecords.where((r) => r.status == AttendanceStatus.absent).length;

  int get leaveCount =>
      todayRecords.where((r) => r.status == AttendanceStatus.leave).length;

  int get lateCount =>
      todayRecords.where((r) => r.status == AttendanceStatus.late).length;

  int get pendingWhatsAppCount => todayRecords
      .where((r) => r.status == AttendanceStatus.absent && !r.whatsappSent)
      .length;

  double getAttendancePercentage(int totalStudents) {
    if (totalStudents == 0) return 0.0;
    return (presentCount / totalStudents) * 100;
  }
}
