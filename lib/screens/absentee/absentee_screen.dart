import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/attendance_model.dart';
import '../../core/services/whatsapp_service.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';

class AbsenteeScreen extends StatelessWidget {
  const AbsenteeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context);
    final attProv = Provider.of<AttendanceProvider>(context);

    final todayRecords = attProv.todayRecords;
    final absenteesRecords = todayRecords
        .where((r) => r.status == AttendanceStatus.absent)
        .toList();

    final allStudents = studentProv.allStudents;

    return Scaffold(
      body: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.absent.withOpacity(0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.mark_chat_unread, color: AppColors.absent),
                    const SizedBox(width: 8),
                    Text(
                      "آج کے غیر حاضرین: ${absenteesRecords.length}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.absent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "تاریخ: ${attProv.selectedDate} • ایک کلک سے والدین کو واٹس ایپ الرٹ بھیجیں",
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Absentees List View
          Expanded(
            child: absenteesRecords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: AppColors.present),
                        const SizedBox(height: 12),
                        const Text(
                          "آج کوئی طالب علم غیر حاضر نہیں ہے!",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: absenteesRecords.length,
                    itemBuilder: (context, index) {
                      final record = absenteesRecords[index];
                      final student = allStudents.firstWhere(
                        (s) => s.id.toString() == record.studentId,
                        orElse: () => allStudents.first,
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.absent.withOpacity(0.12),
                                child: Text(
                                  '${student.rollNo}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.absent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Text(
                                      "ولدیت: ${student.fatherName}",
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      "فون: ${student.whatsappNumber}",
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),

                              // WhatsApp Alert Button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final success = await WhatsAppService.sendAbsenteeAlert(
                                    phoneNumber: student.whatsappNumber,
                                    studentName: student.name,
                                    date: attProv.selectedDate,
                                  );
                                  if (success) {
                                    attProv.markWhatsAppSent(student.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("${student.name} کے والد کو پیغام بھیج دیا گیا"),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.send, size: 16),
                                label: Text(
                                  record.whatsappSent ? "دوبارہ بھیجیں" : "الرٹ بھیجیں",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: record.whatsappSent
                                      ? AppColors.textSecondary
                                      : AppColors.whatsappGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
