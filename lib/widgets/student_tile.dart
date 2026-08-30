import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/models/student_model.dart';

class StudentTile extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;
  final VoidCallback? onWhatsAppTap;

  const StudentTile({
    super.key,
    required this.student,
    required this.onTap,
    this.onWhatsAppTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            '${student.rollNo}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          'ولدیت: ${student.fatherName} | ${student.currentPara} (${student.daurStatus})',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: student.feePaidThisMonth
                    ? AppColors.present.withOpacity(0.1)
                    : AppColors.absent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                student.feePaidThisMonth ? 'فیس ادا' : 'فیس واجب',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: student.feePaidThisMonth ? AppColors.present : AppColors.absent,
                ),
              ),
            ),
            if (onWhatsAppTap != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.whatsappGreen, size: 20),
                onPressed: onWhatsAppTap,
                tooltip: 'واٹس ایپ الرٹ',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
