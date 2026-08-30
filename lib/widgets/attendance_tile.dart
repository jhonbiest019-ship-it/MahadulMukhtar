import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/models/student_model.dart';
import '../core/models/attendance_model.dart';
import '../core/services/whatsapp_service.dart';

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
    final isAbsent = currentStatus == AttendanceStatus.absent;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                // Roll No Badge
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(
                    '${student.rollNo}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

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
                const SizedBox(width: 3),
                _statusButton(AttendanceStatus.absent, 'غائب', AppColors.absent),
                const SizedBox(width: 3),
                _statusButton(AttendanceStatus.leave, 'رخصت', AppColors.leave),
                const SizedBox(width: 3),
                _statusButton(AttendanceStatus.late, 'تاخیر', AppColors.late),
              ],
            ),

            if (isAbsent && !student.isSuspended) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: () {
                    WhatsAppService.sendAbsenteeAlert(
                      phoneNumber: student.phoneNumber,
                      studentName: student.name,
                    );
                  },
                  icon: const Icon(Icons.send, size: 14, color: Colors.white),
                  label: const Text("📱 واٹس ایپ الرٹ بھیجیں", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.present,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: const Size(0, 28),
                  ),
                ),
              ),
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
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
