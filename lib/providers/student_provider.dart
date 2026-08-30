import 'package:flutter/foundation.dart';
import '../core/models/student_model.dart';
import '../core/services/seeder_service.dart';
import '../core/services/firebase_service.dart';

class StudentProvider with ChangeNotifier {
  List<StudentModel> _students = [];
  String _searchQuery = '';

  List<StudentModel> get students {
    if (_searchQuery.isEmpty) return List.unmodifiable(_students);
    return List.unmodifiable(_students.where((s) =>
        s.name.contains(_searchQuery) ||
        s.fatherName.contains(_searchQuery) ||
        s.rollNo.toString().contains(_searchQuery)));
  }

  List<StudentModel> get allStudents => _students;
  String get searchQuery => _searchQuery;
  
  List<StudentModel> get activeStudents => 
      _students.where((s) => !s.isSuspended).toList();

  int get totalCount => _students.length;
  int get presentCount => activeStudents.where((s) => s.status == 'P').length;
  int get absentCount => activeStudents.where((s) => s.status == 'A').length;
  int get suspendedCount => _students.where((s) => s.isSuspended).length;

  StudentProvider([dynamic storageService]) {
    _loadInitialData();
  }

  void _loadInitialData() {
    _students = SeederService.getInitialStudents();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadStudents() async {
    notifyListeners();
  }

  void addStudent(StudentModel student) {
    _students.add(student);
    FirebaseCloudSyncService().syncStudentToCloud(student);
    notifyListeners();
  }

  void updateStudent(StudentModel student) {
    int idx = _students.indexWhere((s) => s.rollNo == student.rollNo);
    if (idx != -1) {
      _students[idx] = student;
      FirebaseCloudSyncService().syncStudentToCloud(student);
      notifyListeners();
    }
  }

  void deleteStudent(int rollNo) {
    _students.removeWhere((s) => s.rollNo == rollNo);
    notifyListeners();
  }

  void toggleSuspend(int rollNo) {
    int idx = _students.indexWhere((s) => s.rollNo == rollNo);
    if (idx != -1) {
      _students[idx].isSuspended = !_students[idx].isSuspended;
      FirebaseCloudSyncService().syncStudentToCloud(_students[idx]);
      notifyListeners();
    }
  }

  void setStatus(int rollNo, String status) {
    int idx = _students.indexWhere((s) => s.rollNo == rollNo);
    if (idx != -1 && !_students[idx].isSuspended) {
      _students[idx].status = status;
      FirebaseCloudSyncService().syncAttendanceToCloud(
        date: DateTime.now().toString().split(' ')[0],
        studentRoll: rollNo,
        status: status,
      );
      notifyListeners();
    }
  }

  void markAllPresent() {
    String today = DateTime.now().toString().split(' ')[0];
    for (var s in _students) {
      if (!s.isSuspended) {
        s.status = 'P';
        FirebaseCloudSyncService().syncAttendanceToCloud(
          date: today,
          studentRoll: s.rollNo,
          status: 'P',
        );
      }
    }
    notifyListeners();
  }
}
