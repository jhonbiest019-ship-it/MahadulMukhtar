import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/hifz_progress_model.dart';
import '../core/models/student_model.dart';

class HifzProvider extends ChangeNotifier {
  static const String keyHifzRecords = 'madrasa_hifz_records_v1';
  late SharedPreferences _prefs;

  List<HifzProgressRecord> _records = [];
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  HifzProvider() {
    _initStorage();
  }

  String get selectedDate => _selectedDate;
  List<HifzProgressRecord> get allRecords => _records;

  List<HifzProgressRecord> get todayRecords =>
      _records.where((r) => r.date == _selectedDate).toList();

  Future<void> _initStorage() async {
    _prefs = await SharedPreferences.getInstance();
    final rawJson = _prefs.getString(keyHifzRecords);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(rawJson);
        _records = list.map((e) => HifzProgressRecord.fromJson(e)).toList();
      } catch (_) {
        _records = [];
      }
    }
    notifyListeners();
  }

  void setSelectedDate(String date, List<StudentModel> students) {
    _selectedDate = date;
    ensureHifzRecordsExist(students);
    notifyListeners();
  }

  void ensureHifzRecordsExist(List<StudentModel> students) {
    final existing = todayRecords;
    if (existing.isEmpty && students.isNotEmpty) {
      for (final std in students) {
        final paraNum = (std.rollNo % 30) + 1;
        _records.add(
          HifzProgressRecord(
            id: 'hifz_${std.id}_$_selectedDate',
            studentId: std.id,
            date: _selectedDate,
            sabaq: 'پارہ $paraNum، 10 سطریں',
            sabqi: 'پارہ ${paraNum > 1 ? paraNum - 1 : 30} پاؤ 4',
            manzil: 'پارہ ${(paraNum + 5) % 30 + 1}',
            mistakes: std.rollNo % 4 == 0 ? '2 غلطیاں' : '0 غلطیاں',
            quality: std.rollNo % 4 == 0 ? 'مناسب' : (std.rollNo % 3 == 0 ? 'عمدہ' : 'ممتاز'),
          ),
        );
      }
      _saveRecords();
    }
  }

  Future<void> saveHifzEntry(HifzProgressRecord record) async {
    final index = _records.indexWhere(
      (r) => r.studentId == record.studentId && r.date == record.date,
    );
    if (index != -1) {
      _records[index] = record;
    } else {
      _records.add(record);
    }
    await _saveRecords();
    notifyListeners();
  }

  Future<void> _saveRecords() async {
    final rawJson = jsonEncode(_records.map((e) => e.toJson()).toList());
    await _prefs.setString(keyHifzRecords, rawJson);
  }

  HifzProgressRecord getStudentHifz(String studentId) {
    return _records.firstWhere(
      (r) => r.studentId == studentId && r.date == _selectedDate,
      orElse: () => HifzProgressRecord(
        id: 'hifz_${studentId}_$_selectedDate',
        studentId: studentId,
        date: _selectedDate,
        sabaq: 'پارہ 1',
        sabqi: 'پارہ 1 پاؤ 1',
        manzil: 'پارہ 10',
        mistakes: '0 غلطیاں',
        quality: 'ممتاز',
      ),
    );
  }
}
