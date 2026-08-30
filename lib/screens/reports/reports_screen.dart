import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/pdf_service.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/fee_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context);
    final attProv = Provider.of<AttendanceProvider>(context);
    final feeProv = Provider.of<FeeProvider>(context);

    feeProv.ensureFeesExist(studentProv.allStudents);

    final students = studentProv.allStudents;
    final paidCount = feeProv.paidCount;
    final unpaidCount = feeProv.unpaidCount;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PDF Export Banner
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.primary,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, size: 40, color: Colors.white),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ماہانہ حاضری رپورٹ پی ڈی ایف",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "تاریخ: ${attProv.selectedDate} • پرنٹ یا شیئر کریں",
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (students.isNotEmpty) {
                          PdfService.printHifzHistoryReport(
                            student: students[0],
                            history: [],
                            rangeTitle: attProv.selectedDate,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("پرنٹ کریں"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Financial Fee Summary Header
            const Text(
              "مالیاتی صورتحال و فیس (Fee Ledger)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _feeStatTile("ادا شدہ فیس", "$paidCount طلباء", AppColors.present),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _feeStatTile("واجب الادا فیس", "$unpaidCount طلباء", AppColors.absent),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Fee Ledger Student List
            const Text(
              "فیس ہسٹری (ماہانہ)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final std = students[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text('#${std.rollNo}', style: const TextStyle(color: AppColors.primary)),
                    ),
                    title: Text(std.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("والد: ${std.fatherName} | فیس: 1500 روپے"),
                    trailing: TextButton(
                      onPressed: () {
                        feeProv.toggleFeeStatus(std.id);
                        studentProv.updateStudent(std.copyWith(feePaidThisMonth: !std.feePaidThisMonth));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: std.feePaidThisMonth ? AppColors.present.withOpacity(0.1) : AppColors.absent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          std.feePaidThisMonth ? "اداکردہ" : "غیر ادا",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: std.feePaidThisMonth ? AppColors.present : AppColors.absent,
                          ),
                        ),
                      ),
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

  Widget _feeStatTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
