import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../widgets/student_tile.dart';
import 'student_detail_screen.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context);
    final students = studentProv.students;

    return Scaffold(
      body: Column(
        children: [
          // Search Bar Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) => studentProv.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: "نام، رول نمبر یا پارہ سے تلاش کریں...",
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: studentProv.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => studentProv.setSearchQuery(''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),

          // Total Count Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "کل طلباء: ${students.length}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),

          // Students List
          Expanded(
            child: students.isEmpty
                ? const Center(child: Text("کوئی طالب علم تلاش نہیں ہوا"))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return StudentTile(
                        student: student,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentDetailScreen(student: student),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentModal(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text("نیا طالب علم", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddStudentModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final fatherCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final paraCtrl = TextEditingController(text: 'پارہ 1');
    final rollCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "نیا طالب علم داخل کریں",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "طالب علم کا نام", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: fatherCtrl,
                decoration: const InputDecoration(labelText: "ولدیت", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "واٹس ایپ نمبر (e.g. 03001234567)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: rollCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "رول نمبر", border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: paraCtrl,
                      decoration: const InputDecoration(labelText: "موجودہ پارہ", border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty && fatherCtrl.text.isNotEmpty) {
                      final newStd = StudentModel(
                        rollNo: int.tryParse(rollCtrl.text) ?? (DateTime.now().millisecondsSinceEpoch % 1000),
                        name: nameCtrl.text,
                        fatherName: fatherCtrl.text,
                        phoneNumber: phoneCtrl.text.isEmpty ? '03000000000' : phoneCtrl.text,
                        currentPara: paraCtrl.text,
                        daurStatus: 'ناظرہ / سبق',
                      );
                      Provider.of<StudentProvider>(context, listen: false).addStudent(newStd);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("محفوظ کریں", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
