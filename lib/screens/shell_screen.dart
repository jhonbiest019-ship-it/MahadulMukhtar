import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../widgets/custom_drawer.dart';
import 'dashboard/dashboard_screen.dart';
import 'attendance/attendance_screen.dart';
import 'absentee/absentee_screen.dart';
import 'students/student_list_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  final List<String> _titles = [
    AppStrings.appTitle,
    AppStrings.navAttendance,
    AppStrings.navAbsentees,
    AppStrings.navStudents,
    AppStrings.navReports,
    AppStrings.navSettings,
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onNavigate: (index) => setState(() => _currentIndex = index)),
      const AttendanceScreen(),
      const AbsenteeScreen(),
      const StudentListScreen(),
      const ReportsScreen(),
      const SettingsScreen(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl, // RTL layout for Urdu
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _titles[_currentIndex],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.mosque),
              onPressed: () {},
              tooltip: AppStrings.appTitle,
            ),
          ],
        ),
        drawer: CustomDrawer(
          selectedIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: AppStrings.navDashboard,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fact_check_outlined),
              activeIcon: Icon(Icons.fact_check),
              label: AppStrings.navAttendance,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mark_chat_unread_outlined),
              activeIcon: Icon(Icons.mark_chat_unread),
              label: AppStrings.navAbsentees,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: AppStrings.navStudents,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.picture_as_pdf_outlined),
              activeIcon: Icon(Icons.picture_as_pdf),
              label: AppStrings.navReports,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: AppStrings.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
