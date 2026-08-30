import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/student_model.dart';
import '../../core/models/hifz_progress_model.dart';
import '../../core/services/pdf_service.dart';
import '../../core/services/whatsapp_service.dart';
import '../../providers/student_provider.dart';
import '../../providers/hifz_provider.dart';
import '../../providers/attendance_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedRange = 'weekly'; // 'weekly', 'monthly', 'custom'

  @override
  Widget build(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context);
    final hifzProv = Provider.of<HifzProvider>(context);
    final attProv = Provider.of<AttendanceProvider>(context);

    final students = studentProv.allStudents.isNotEmpty
        ? studentProv.allStudents
        : [
            StudentModel(
              rollNo: 1,
              name: "عبداللہ خان",
              fatherName: "محمد عثمان",
              currentPara: "پارہ 1",
              phoneNumber: "03001234567",
              status: "P",
              isSuspended: false,
            )
          ];

    final records = hifzProv.allRecords;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PDF & WhatsApp Banner Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bar_chart, size: 28, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "روزانہ کارکردگی ہسٹری (Date Log)",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "سبق، سبقی، منزل، حاضری اور غلطیوں کا مکمل تاریچی ریکارڈ۔",
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),

                    // Range Selectors
                    Row(
                      children: [
                        _rangeBtn("📅 ہفتہ وار", 'weekly'),
                        const SizedBox(width: 6),
                        _rangeBtn("🗓️ ماہانہ", 'monthly'),
                        const SizedBox(width: 6),
                        _rangeBtn("⚙️ کسٹم", 'custom'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Share & Print Actions
            if (students.isNotEmpty)
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final s = students.first;
                            final rec = hifzProv.getStudentHifz(s.id);
                            final msg = "📋 *Al Mukhtar Islamic Institute*\nطالب علم: *${s.name}* (#${s.rollNo})\nسبق: ${rec.sabaq}\nسبقی: ${rec.sabqi}\nمنزل: ${rec.manzil}\nغلطیاں: ${rec.mistakes} | کیفیت: ${rec.quality}\n\nDesigned by Muhammad Irfan";
                            WhatsAppService.sendAbsenteeAlert(phoneNumber: s.phoneNumber, studentName: s.name);
                          },
                          icon: const Icon(Icons.send, size: 16, color: Colors.white),
                          label: const Text("📱 واٹس ایپ رپورٹ", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.present),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (students.isNotEmpty) {
                              PdfService.printHifzHistoryReport(
                                student: students.first,
                                history: records,
                                rangeTitle: attProv.selectedDate,
                              );
                            }
                          },
                          icon: const Icon(Icons.print, size: 16),
                          label: const Text("🖨️ PDF پرنٹ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 14),

            // History Log List
            const Text(
              "روزانہ کارکردگی ہسٹری (All History Logs)",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 8),

            records.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: const Text("ابھی کوئی تاریخی ریکارڈ موجود نہیں ہے", style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final rec = records[index];
                      final student = students.firstWhere((s) => s.id.toString() == rec.studentId, orElse: () => students.first);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text("${rec.date} - ${student.name} (#${student.rollNo})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text("سبق: ${rec.sabaq} | سبقی: ${rec.sabqi} | منزل: ${rec.manzil}\nغلطیاں: ${rec.mistakes} | کیفیت: ${rec.quality}", style: const TextStyle(fontSize: 11)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.present.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(rec.quality, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.present)),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _rangeBtn(String label, String mode) {
    final isSelected = _selectedRange == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedRange = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
