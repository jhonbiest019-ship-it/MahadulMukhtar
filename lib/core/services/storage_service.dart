import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../models/fee_model.dart';

class StorageService {
  static const String keyStudents = 'madrasa_students_list_v1';
  static const String keyAttendance = 'madrasa_attendance_list_v1';
  static const String keyFees = 'madrasa_fees_list_v1';
  static const String keyIsSeeded = 'madrasa_is_seeded_v1';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isSeeded => _prefs.getBool(keyIsSeeded) ?? false;

  Future<void> setSeeded(bool val) async {
    await _prefs.setBool(keyIsSeeded, val);
  }

  // SAVE & LOAD STUDENTS
  Future<void> saveStudents(List<StudentModel> students) async {
    final rawJson = jsonEncode(students.map((e) => e.toJson()).toList());
    await _prefs.setString(keyStudents, rawJson);
  }

  List<StudentModel> getStudents() {
    final rawJson = _prefs.getString(keyStudents);
    if (rawJson == null || rawJson.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((e) => StudentModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // SAVE & LOAD ATTENDANCE
  Future<void> saveAttendance(List<AttendanceRecord> records) async {
    final rawJson = jsonEncode(records.map((e) => e.toJson()).toList());
    await _prefs.setString(keyAttendance, rawJson);
  }

  List<AttendanceRecord> getAttendance() {
    final rawJson = _prefs.getString(keyAttendance);
    if (rawJson == null || rawJson.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // SAVE & LOAD FEES
  Future<void> saveFees(List<FeeRecord> fees) async {
    final rawJson = jsonEncode(fees.map((e) => e.toJson()).toList());
    await _prefs.setString(keyFees, rawJson);
  }

  List<FeeRecord> getFees() {
    final rawJson = _prefs.getString(keyFees);
    if (rawJson == null || rawJson.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((e) => FeeRecord.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}
