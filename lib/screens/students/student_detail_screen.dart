import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/fee_provider.dart';

class StudentDetailScreen extends StatefulWidget {
  final StudentModel student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late TextEditingController _paraCtrl;
  late TextEditingController _daurCtrl;

  @override
  void initState() {
    super.initState();
    _paraCtrl = TextEditingController(text: widget.student.currentPara);
    _daurCtrl = TextEditingController(text: widget.student.daurStatus);
  }

  @override
  void dispose() {
    _paraCtrl.dispose();
    _daurCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context);
    final feeProv = Provider.of<FeeProvider>(context);
    final std = widget.student;

    return Scaffold(
      appBar: AppBar(
        title: Text(std.name),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      child: Text(
                        '#${std.rollNo}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            std.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "ولدیت: ${std.fatherName}",
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                          Text(
                            "فون: ${std.phoneNumber}",
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sabaq & Hifz Progress Tracker Form
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "سبق و حفظ کی معلومات (Academic Tracker)",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _paraCtrl,
                      decoration: const InputDecoration(
                        labelText: "موجودہ پارہ / سبق",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _daurCtrl,
                      decoration: const InputDecoration(
                        labelText: "دور / ناظرہ سٹیٹس",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.auto_stories, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final updated = std.copyWith(
                            currentPara: _paraCtrl.text,
                            daurStatus: _daurCtrl.text,
                          );
                          studentProv.updateStudent(updated);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("سبق کی معلومات اپڈیٹ کر دی گئی ہیں")),
                          );
                        },
                        icon: const Icon(Icons.save),
                        label: const Text("سبق محفوظ کریں"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fee Status Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ماہانہ فیس کی صورتحال",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          feeProv.currentMonth,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        feeProv.toggleFeeStatus(std.id);
                        studentProv.updateStudent(std.copyWith(feePaidThisMonth: !std.feePaidThisMonth));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: std.feePaidThisMonth ? AppColors.present : AppColors.absent,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(std.feePaidThisMonth ? "اداکردہ" : "واجب الادا"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
