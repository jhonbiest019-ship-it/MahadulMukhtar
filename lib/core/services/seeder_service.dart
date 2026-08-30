import '../models/student_model.dart';
import '../models/attendance_model.dart';

class SeederService {
  static List<StudentModel> getInitialStudents() {
    return [
      StudentModel(
        rollNo: 1,
        name: "عبداللہ خان",
        fatherName: "محمد عثمان",
        currentPara: "پارہ 1",
        phoneNumber: "03001234567",
        feePaid: true,
        status: 'P',
        isSuspended: false,
      ),
    ];
  }

  static List<AttendanceRecord> getInitialAttendance(List<StudentModel> students, String date) {
    return students.map((s) => AttendanceRecord(
      id: 'att_${s.id}_$date',
      studentId: s.id.toString(),
      date: date,
      status: AttendanceStatus.present,
    )).toList();
  }
}
