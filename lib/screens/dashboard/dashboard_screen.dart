import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context);
    final attProv = Provider.of<AttendanceProvider>(context);

    // Make sure today's records are loaded
    attProv.ensureDateRecordsExist(studentProv.allStudents);

    final totalStudents = studentProv.totalCount;
    final presentCount = attProv.presentCount;
    final absentCount = attProv.absentCount;
    final pendingWhatsApp = attProv.pendingWhatsAppCount;
    final percentage = attProv.getAttendancePercentage(totalStudents);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header Card
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "بسم اللہ الرحمن الرحیم",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          AppStrings.appTitle,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "آج کی تاریخ: ${attProv.selectedDate}",
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mosque, color: Colors.white, size: 36),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Attendance Percentage Banner
          Card(
            color: AppColors.primaryLight.withOpacity(0.12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "آج حاضری کی شرح:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    "${percentage.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // KPI Stats Grid (2x2)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              StatCard(
                title: AppStrings.totalStudents,
                value: '$totalStudents',
                icon: Icons.people,
                color: AppColors.primary,
                onTap: () => onNavigate(3), // Navigate to Students
              ),
              StatCard(
                title: AppStrings.presentToday,
                value: '$presentCount',
                icon: Icons.check_circle,
                color: AppColors.present,
                onTap: () => onNavigate(1), // Navigate to Attendance
              ),
              StatCard(
                title: AppStrings.absentToday,
                value: '$absentCount',
                icon: Icons.cancel,
                color: AppColors.absent,
                onTap: () => onNavigate(2), // Navigate to Absentees
              ),
              StatCard(
                title: AppStrings.alertPending,
                value: '$pendingWhatsApp',
                icon: Icons.mark_chat_unread,
                color: AppColors.whatsappGreen,
                onTap: () => onNavigate(2), // Navigate to WhatsApp alerts
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Fast Action Buttons Section
          const Text(
            "فوری اقدامات (Quick Actions)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onNavigate(1), // Take Attendance
                  icon: const Icon(Icons.fact_check),
                  label: const Text("حاضری لگائیں"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onNavigate(2), // Send WhatsApp alerts
                  icon: const Icon(Icons.send),
                  label: const Text("واٹس ایپ الرٹس"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.whatsappGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => onNavigate(4), // View Reports & PDF
              icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
              label: const Text("پی ڈی ایف رپورٹ دیکھیں", style: TextStyle(color: AppColors.primary)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
