import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/storage_service.dart';
import '../../providers/student_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = Provider.of<StorageService>(context, listen: false);
    final backupService = BackupService(storageService);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // App Title Card
          Card(
            child: ListTile(
              leading: const Icon(Icons.mosque, color: AppColors.primary, size: 36),
              title: const Text(AppStrings.appTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: const Text(AppStrings.appSubtitle, style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 12),

          // Backup & Restore Section
          const Text(
            "بیک اپ اور بحالی (Backup & Restore)",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 6),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download, color: AppColors.primary),
                  title: const Text("بیک اپ ایکسپورٹ کریں (JSON)"),
                  subtitle: const Text("ڈیٹا کا JSON ٹیکسٹ بفر میں کاپی کریں"),
                  onTap: () {
                    final jsonStr = backupService.exportToJson();
                    Clipboard.setData(ClipboardData(text: jsonStr));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("بیک اپ JSON کاپی کر لیا گیا ہے")),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.refresh, color: AppColors.accent),
                  title: const Text("سیمپل ڈیٹا دوبارہ لوڈ کریں"),
                  subtitle: const Text("40 ابتدائی طلباء کا ریکارڈ دوبارہ ری سیٹ کریں"),
                  onTap: () async {
                    await storageService.clearAllData();
                    await Provider.of<StudentProvider>(context, listen: false).loadStudents();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("ڈیٹا دوبارہ ری سیٹ کر دیا گیا ہے")),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Developer Credit & Branding Card
          Card(
            color: AppColors.primary.withOpacity(0.06),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.code, size: 32, color: AppColors.primary),
                  const SizedBox(height: 8),
                  const Text(
                    "مدرسۃ المختار ڈیجیٹل سسٹم",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AppStrings.developerCredit,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Offline-First Flutter Android Application\nSupports Urdu RTL & WhatsApp Intents",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
