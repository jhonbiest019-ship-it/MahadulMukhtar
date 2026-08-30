import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/attendance_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/attendance_tile.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context);
    final attProv = Provider.of<AttendanceProvider>(context);

    final students = studentProv.students;

    return Scaffold(
      body: Column(
        children: [
          // Header Bar with Date Picker & Mark All Present Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.primary.withOpacity(0.06),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date Selector Chip
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(attProv.selectedDate),
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      final str = DateFormat('yyyy-MM-dd').format(picked);
                      attProv.setSelectedDate(str, studentProv.allStudents);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          attProv.selectedDate,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

                // Mark All Present Action Button
                ElevatedButton.icon(
                  onPressed: () {
                    attProv.markAllPresent(students);
                    studentProv.markAllPresent();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("تمام طلباء کو حاضر مارک کر دیا گیا ہے"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text(AppStrings.markAllPresent, style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.present,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          // Attendance Summary Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryChip("حاضر: ${attProv.presentCount}", AppColors.present),
                _summaryChip("غائب: ${attProv.absentCount}", AppColors.absent),
                _summaryChip("رخصت: ${attProv.leaveCount}", AppColors.leave),
                _summaryChip("تاخیر: ${attProv.lateCount}", AppColors.late),
              ],
            ),
          ),

          const Divider(height: 1),

          // Student Fast Attendance Marking List
          Expanded(
            child: students.isEmpty
                ? const Center(child: Text("کوئی طالب علم موجود نہیں"))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 6, bottom: 80),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final currentStatus = attProv.getStudentStatus(student.id);

                      return AttendanceTile(
                        student: student,
                        currentStatus: currentStatus,
                        onStatusChanged: (newStatus) {
                          attProv.updateStatus(student.id, newStatus);
                          String stCode = 'P';
                          if (newStatus == AttendanceStatus.absent) stCode = 'A';
                          if (newStatus == AttendanceStatus.leave) stCode = 'L';
                          if (newStatus == AttendanceStatus.late) stCode = 'T';
                          studentProv.setStatus(student.rollNo, stCode);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
