import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/hifz_progress_model.dart';
import '../../core/models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/hifz_provider.dart';
import '../../core/services/firebase_service.dart';

class HifzTrackerScreen extends StatefulWidget {
  const HifzTrackerScreen({super.key});

  @override
  State<HifzTrackerScreen> createState() => _HifzTrackerScreenState();
}

class _HifzTrackerScreenState extends State<HifzTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context);
    final hifzProv = Provider.of<HifzProvider>(context);

    hifzProv.ensureHifzRecordsExist(studentProv.allStudents);
    final students = studentProv.students;

    return Scaffold(
      body: Column(
        children: [
          // Date Picker & Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.primary.withOpacity(0.06),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(hifzProv.selectedDate),
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      final str = DateFormat('yyyy-MM-dd').format(picked);
                      hifzProv.setSelectedDate(str, studentProv.allStudents);
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
                          "تاریخ: ${hifzProv.selectedDate}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const Text(
                  "روزانہ سبق، سبقی و منزل ٹریکر",
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),

          // Daily Hifz Progress List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final record = hifzProv.getStudentHifz(student.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "#${student.rollNo} - ${student.name}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            _qualityBadge(record.quality),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(child: Text("سبق: ${record.sabaq}", style: const TextStyle(fontSize: 12))),
                            Expanded(child: Text("سبقی: ${record.sabqi}", style: const TextStyle(fontSize: 12))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(child: Text("منزل: ${record.manzil}", style: const TextStyle(fontSize: 12))),
                            Expanded(
                              child: Text(
                                "غلطیاں: ${record.mistakes}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: record.mistakes.contains('0') ? AppColors.present : AppColors.absent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _showStudentSlipDialog(context, student, record, hifzProv.selectedDate),
                              icon: const Icon(Icons.print, size: 16),
                              label: const Text("🖨️ سلپ پرنٹ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showEditHifzModal(context, student, record),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text("سبق کیفیّت تبدیل کریں", style: TextStyle(fontSize: 12)),
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGlobalSearchHifzModal(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.search, color: Colors.white),
        label: const Text("سبق درج / اپڈیٹ کریں", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _qualityBadge(String quality) {
    Color color = AppColors.present;
    if (quality == 'مناسب') color = AppColors.leave;
    if (quality == 'توجہ طلب' || quality == 'توجہ-طلب') color = AppColors.absent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        quality,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  void _showGlobalSearchHifzModal(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context, listen: false);
    final hifzProv = Provider.of<HifzProvider>(context, listen: false);
    final students = studentProv.allStudents;

    if (students.isEmpty) return;

    StudentModel selectedStudent = students.first;
    HifzProgressRecord currentRecord = hifzProv.getStudentHifz(selectedStudent.id);

    final searchCtrl = TextEditingController();
    final sabaqCtrl = TextEditingController(text: currentRecord.sabaq);
    final sabqiCtrl = TextEditingController(text: currentRecord.sabqi);
    final manzilCtrl = TextEditingController(text: currentRecord.manzil);
    final mistakesCtrl = TextEditingController(text: currentRecord.mistakes);
    String selectedQuality = currentRecord.quality;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchCtrl.text.trim().toLowerCase();
            final searchResults = query.isEmpty
                ? <StudentModel>[]
                : students.where((s) =>
                    s.name.toLowerCase().contains(query) ||
                    s.fatherName.toLowerCase().contains(query) ||
                    s.rollNo.toString().contains(query)).toList();

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
                    const Text(
                      "📖 روزانہ سبق، سبقی و منزل اندراج",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),

                    // Search Bar
                    TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        labelText: "🔍 طالب علم تلاش کریں (Search)",
                        hintText: "نام یا رول نمبر لکھیں...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),

                    if (searchResults.isNotEmpty)
                      Container(
                        maxHeight: 120,
                        margin: const EdgeInsets.only(top: 4, bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchResults.length,
                          itemBuilder: (c, i) {
                            final s = searchResults[i];
                            return ListTile(
                              dense: true,
                              title: Text("${s.name} (#${s.rollNo})", style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("ولدیت: ${s.fatherName} | پارہ: ${s.currentPara}"),
                              onTap: () {
                                setModalState(() {
                                  selectedStudent = s;
                                  currentRecord = hifzProv.getStudentHifz(s.id);
                                  sabaqCtrl.text = currentRecord.sabaq;
                                  sabqiCtrl.text = currentRecord.sabqi;
                                  manzilCtrl.text = currentRecord.manzil;
                                  mistakesCtrl.text = currentRecord.mistakes;
                                  selectedQuality = currentRecord.quality;
                                  searchCtrl.clear();
                                });
                              },
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 10),
                    // Selected Student Summary Box
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "منتخب طالب علم: ${selectedStudent.name} (رول #${selectedStudent.rollNo})\nولدیت: ${selectedStudent.fatherName}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: sabaqCtrl,
                      decoration: const InputDecoration(labelText: "آج کا سبق (Sabaq)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: sabqiCtrl,
                      decoration: const InputDecoration(labelText: "سبقی (Sabqi)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: manzilCtrl,
                      decoration: const InputDecoration(labelText: "منزل (Manzil)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: mistakesCtrl,
                      decoration: const InputDecoration(labelText: "غلطیاں (Mistakes)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: selectedQuality,
                      decoration: const InputDecoration(labelText: "کیفیت / Grade", border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: "ممتاز", child: Text("ممتاز (Excellent)")),
                        DropdownMenuItem(value: "عمدہ", child: Text("عمدہ (Good)")),
                        DropdownMenuItem(value: "مناسب", child: Text("مناسب (Average)")),
                        DropdownMenuItem(value: "توجہ طلب", child: Text("توجہ طلب (Needs Work)")),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedQuality = val);
                      },
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final updated = currentRecord.copyWith(
                            sabaq: sabaqCtrl.text,
                            sabqi: sabqiCtrl.text,
                            manzil: manzilCtrl.text,
                            mistakes: mistakesCtrl.text,
                            quality: selectedQuality,
                          );
                          hifzProv.saveHifzEntry(updated);
                          FirebaseCloudSyncService().syncHifzRecordToCloud(
                            date: hifzProv.selectedDate,
                            studentRoll: selectedStudent.rollNo,
                            sabaq: sabaqCtrl.text,
                            sabqi: sabqiCtrl.text,
                            manzil: manzilCtrl.text,
                            mistakes: mistakesCtrl.text,
                            quality: selectedQuality,
                          );
                          Navigator.pop(ctx);
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
              ),
            );
          },
        );
      },
    );
  }

  void _showEditHifzModal(BuildContext context, StudentModel student, HifzProgressRecord record) {
    final sabaqCtrl = TextEditingController(text: record.sabaq);
    final sabqiCtrl = TextEditingController(text: record.sabqi);
    final manzilCtrl = TextEditingController(text: record.manzil);
    final mistakesCtrl = TextEditingController(text: record.mistakes);
    String selectedQuality = record.quality;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    Text(
                      "${student.name} (رول #${student.rollNo}) - سبق کیفیّت اپڈیٹ",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: sabaqCtrl,
                      decoration: const InputDecoration(labelText: "آج کا سبق (Sabaq)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: sabqiCtrl,
                      decoration: const InputDecoration(labelText: "سبقی (Sabqi)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: manzilCtrl,
                      decoration: const InputDecoration(labelText: "منزل (Manzil)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: mistakesCtrl,
                      decoration: const InputDecoration(labelText: "غلطیاں (Mistakes)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: selectedQuality,
                      decoration: const InputDecoration(labelText: "کیفیت / Grade", border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: "ممتاز", child: Text("ممتاز (Excellent)")),
                        DropdownMenuItem(value: "عمدہ", child: Text("عمدہ (Good)")),
                        DropdownMenuItem(value: "مناسب", child: Text("مناسب (Average)")),
                        DropdownMenuItem(value: "توجہ طلب", child: Text("توجہ طلب (Needs Work)")),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedQuality = val);
                      },
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final updated = record.copyWith(
                            sabaq: sabaqCtrl.text,
                            sabqi: sabqiCtrl.text,
                            manzil: manzilCtrl.text,
                            mistakes: mistakesCtrl.text,
                            quality: selectedQuality,
                          );
                          Provider.of<HifzProvider>(context, listen: false).saveHifzEntry(updated);
                          FirebaseCloudSyncService().syncHifzRecordToCloud(
                            date: Provider.of<HifzProvider>(context, listen: false).selectedDate,
                            studentRoll: student.rollNo,
                            sabaq: sabaqCtrl.text,
                            sabqi: sabqiCtrl.text,
                            manzil: manzilCtrl.text,
                            mistakes: mistakesCtrl.text,
                            quality: selectedQuality,
                          );
                          Navigator.pop(ctx);
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
              ),
            );
          },
        );
      },
    );
  }

  void _showStudentSlipDialog(BuildContext context, StudentModel student, HifzProgressRecord record, String dateStr) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Al Mukhtar Islamic Institute", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("روزانہ طالب علم حاضری و کارکردگی سلپ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 13)),
              const Divider(),
              Text("تاریخ: $dateStr", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("طالب علم: #${student.rollNo} - ${student.name}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text("ولدیت: ${student.fatherName}", style: const TextStyle(fontSize: 12)),
              Text("واٹس ایپ: ${student.phoneNumber}", style: const TextStyle(fontSize: 12)),
              const Divider(),
              Text("آج کا سبق: ${record.sabaq}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text("سبقی: ${record.sabqi}", style: const TextStyle(fontSize: 12)),
              Text("منزل: ${record.manzil}", style: const TextStyle(fontSize: 12)),
              Text("غلطیاں: ${record.mistakes}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.absent)),
              Text("کیفیت: ${record.quality}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("بند کریں"),
            ),
          ],
        );
      },
    );
  }
}
