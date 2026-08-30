import 'dart:convert';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../models/fee_model.dart';
import 'storage_service.dart';

class BackupService {
  final StorageService _storageService;

  BackupService(this._storageService);

  String exportToJson() {
    final students = _storageService.getStudents();
    final attendance = _storageService.getAttendance();
    final fees = _storageService.getFees();

    final map = {
      'app': 'Al Mukhtar Islamic Institute',
      'version': '1.0.0',
      'exportDate': DateTime.now().toIso8601String(),
      'developer': 'Designed and Developed by Muhammad Irfan',
      'students': students.map((e) => e.toJson()).toList(),
      'attendance': attendance.map((e) => e.toJson()).toList(),
      'fees': fees.map((e) => e.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(map);
  }

  Future<bool> importFromJson(String rawJson) async {
    try {
      final Map<String, dynamic> data = jsonDecode(rawJson);
      if (data.containsKey('students')) {
        final List<dynamic> stdList = data['students'];
        final students = stdList.map((e) => StudentModel.fromJson(e)).toList();
        await _storageService.saveStudents(students);
      }

      if (data.containsKey('attendance')) {
        final List<dynamic> attList = data['attendance'];
        final attendance = attList.map((e) => AttendanceRecord.fromJson(e)).toList();
        await _storageService.saveAttendance(attendance);
      }

      if (data.containsKey('fees')) {
        final List<dynamic> feeList = data['fees'];
        final fees = feeList.map((e) => FeeRecord.fromJson(e)).toList();
        await _storageService.saveFees(fees);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
