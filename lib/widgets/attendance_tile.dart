import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/models/student_model.dart';
import '../core/models/attendance_model.dart';

class AttendanceTile extends StatelessWidget {
  final StudentModel student;
  final AttendanceStatus currentStatus;
  final Function(AttendanceStatus) onStatusChanged;

  const AttendanceTile({
    super.key,
    required this.student,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Roll No Badge
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                '${student.rollNo}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Student Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'ولدیت: ${student.fatherName}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // 4 Status Fast Toggles
            _statusButton(AttendanceStatus.present, 'حاضر', AppColors.present),
            const SizedBox(width: 4),
            _statusButton(AttendanceStatus.absent, 'غائب', AppColors.absent),
            const SizedBox(width: 4),
            _statusButton(AttendanceStatus.leave, 'رخصت', AppColors.leave),
            const SizedBox(width: 4),
            _statusButton(AttendanceStatus.late, 'تاخیر', AppColors.late),
          ],
        ),
      ),
    );
  }

  Widget _statusButton(AttendanceStatus status, String label, Color color) {
    final isSelected = currentStatus == status;
    return InkWell(
      onTap: () => onStatusChanged(status),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
