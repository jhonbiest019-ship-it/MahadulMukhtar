import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

class CustomDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            accountName: const Text(
              AppStrings.appTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            accountEmail: const Text(
              AppStrings.appSubtitle,
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.mosque,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // Drawer Navigation Items
          _drawerItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            title: AppStrings.navDashboard,
            index: 0,
            context: context,
          ),
          _drawerItem(
            icon: Icons.fact_check_outlined,
            activeIcon: Icons.fact_check,
            title: AppStrings.navAttendance,
            index: 1,
            context: context,
          ),
          _drawerItem(
            icon: Icons.mark_chat_unread_outlined,
            activeIcon: Icons.mark_chat_unread,
            title: AppStrings.navAbsentees,
            index: 2,
            context: context,
          ),
          _drawerItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            title: AppStrings.navStudents,
            index: 3,
            context: context,
          ),
          _drawerItem(
            icon: Icons.picture_as_pdf_outlined,
            activeIcon: Icons.picture_as_pdf,
            title: AppStrings.navReports,
            index: 4,
            context: context,
          ),
          _drawerItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            title: AppStrings.navSettings,
            index: 5,
            context: context,
          ),

          const Spacer(),
          const Divider(),

          // Mandatory Developer Branding Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                const Icon(Icons.code, size: 18, color: AppColors.primaryLight),
                const SizedBox(height: 4),
                Text(
                  AppStrings.developerCredit,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "v1.0.0 • Offline Ready",
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = selectedIndex == index;
    return ListTile(
      leading: Icon(
        isSelected ? activeIcon : icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.08),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onItemSelected(index);
      },
    );
  }
}
