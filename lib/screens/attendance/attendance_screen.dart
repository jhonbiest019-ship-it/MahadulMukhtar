import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/attendance_model.dart';
import '../../core/models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../core/services/whatsapp_service.dart';
import '../../core/services/firebase_service.dart';
import '../../widgets/attendance_tile.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context);
    final attProv = Provider.of<AttendanceProvider>(context);
    final students = studentProv.allStudents;

    return Scaffold(
      body: Column(
        children: [
          // Header Bar with Date Picker & Firebase Sync Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.primary.withOpacity(0.06),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date Selector Chip
                InkWell(
                  onTap: () async {
                    DateTime initial = DateTime.now();
                    try { initial = DateTime.parse(attProv.selectedDate); } catch (_) {}
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      final str = DateFormat('yyyy-MM-dd').format(picked);
                      attProv.setSelectedDate(str, students);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          attProv.selectedDate,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                // Firebase Live Sync Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.present.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(radius: 4, backgroundColor: AppColors.present),
                      SizedBox(width: 6),
                      Text("🔥 Live Cloud Sync", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.present)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top Action Buttons Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddStudentModal(context),
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
                    label: const Text("➕ نیا طالب علم", style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton.icon(
                    onPressed: () {
                      attProv.markAllPresent(students);
                      studentProv.markAllPresent();
                      for (final s in students) {
                        FirebaseCloudSyncService().syncAttendanceToCloud(
                          date: attProv.selectedDate,
                          studentRoll: s.rollNo,
                          status: 'P',
                        );
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("تمام طلباء کو حاضر مارک کر دیا گیا ہے")),
                      );
                    },
                    icon: const Icon(Icons.done_all, size: 16, color: Colors.white),
                    label: const Text("✔️ سب کو حاضر کریں", style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.present),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton.icon(
                    onPressed: () => _sendAllWhatsAppAlerts(context, students),
                    icon: const Icon(Icons.send, size: 16, color: Colors.white),
                    label: const Text("📱 واٹس ایپ الرٹس بھیجیں", style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.present),
                  ),
                ],
              ),
            ),
          ),

          // Attendance Summary Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                          FirebaseCloudSyncService().syncAttendanceToCloud(
                            date: attProv.selectedDate,
                            studentRoll: student.rollNo,
                            status: stCode,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _sendAllWhatsAppAlerts(BuildContext context, List<StudentModel> students) {
    final absentees = students.where((s) => s.status == 'A' && !s.isSuspended).toList();
    if (absentees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("آج کوئی طالب علم غیر حاضر نہیں ہے!")),
      );
      return;
    }
    for (final s in absentees) {
      WhatsAppService.sendAbsenteeAlert(phoneNumber: s.phoneNumber, studentName: s.name);
    }
  }

  void _showAddStudentModal(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context, listen: false);
    final rollCtrl = TextEditingController(text: '${studentProv.allStudents.length + 1}');
    final nameCtrl = TextEditingController();
    final fatherCtrl = TextEditingController();
    final paraCtrl = TextEditingController(text: 'پارہ 1');
    final phoneCtrl = TextEditingController(text: '03001234567');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("➕ نیا طالب علم شامل کریں", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 12),
                TextField(controller: rollCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "رول نمبر (Roll No)", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "طالب علم کا نام", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: fatherCtrl, decoration: const InputDecoration(labelText: "ولدیت", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: paraCtrl, decoration: const InputDecoration(labelText: "موجودہ پارہ", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "واٹس ایپ نمبر", border: OutlineInputBorder())),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final father = fatherCtrl.text.trim();
                      if (name.isEmpty || father.isEmpty) return;

                      final newStudent = StudentModel(
                        rollNo: int.tryParse(rollCtrl.text) ?? (studentProv.allStudents.length + 1),
                        name: name,
                        fatherName: father,
                        currentPara: paraCtrl.text.trim().isEmpty ? 'پارہ 1' : paraCtrl.text.trim(),
                        phoneNumber: phoneCtrl.text.trim().isEmpty ? '03001234567' : phoneCtrl.text.trim(),
                        status: 'P',
                        isSuspended: false,
                      );
                      studentProv.addStudent(newStudent);
                      FirebaseCloudSyncService().syncStudentToCloud(newStudent);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: const Text("شامل کریں", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
