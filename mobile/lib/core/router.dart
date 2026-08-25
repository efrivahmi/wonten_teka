import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Models
import 'models/company_models.dart';

// Pre-auth
import '../features/onboarding/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/device_binding_screen.dart';
import '../features/attendance/presentation/screens/face_enrollment_screen.dart';
import '../features/onboarding/presentation/screens/app_tour_guide_screen.dart';

// Main Navigation Shell
import 'widgets/bottom_nav_shell.dart';

// Dashboard & Attendance
import '../features/dashboard/presentation/screens/home_dashboard_screen.dart';
import '../features/attendance/presentation/screens/attendance_history_screen.dart';
import '../features/attendance/presentation/screens/face_check_in_screen.dart';
import '../features/attendance/presentation/screens/check_in_success_screen.dart';
import '../features/attendance/presentation/screens/attendance_detail_screen.dart';
import '../features/attendance/presentation/screens/attendance_report_screen.dart';
import '../features/attendance/presentation/screens/attendance_dispute_screen.dart';

// Schedule & Habits
import '../features/schedule/presentation/screens/shift_schedule_screen.dart';
import '../features/schedule_habit/presentation/screens/habit_tracker_screen.dart';
import '../features/schedule_habit/presentation/screens/habit_form_screen.dart';
import '../features/schedule_habit/presentation/screens/habit_detail_screen.dart';

// Leave, Approval, & Claims
import '../features/leave/presentation/screens/leave_request_form_screen.dart';
import '../features/leave/presentation/screens/leave_detail_screen.dart';
import '../features/approval/presentation/screens/approval_inbox_screen.dart';
import '../features/approval/presentation/screens/approval_detail_screen.dart';
import '../features/claims/presentation/screens/claim_list_screen.dart';
import '../features/claims/presentation/screens/claim_submission_screen.dart';
import '../features/claims/presentation/screens/claim_detail_screen.dart';

// Payroll, Calendar, Announcements
import '../features/payroll/presentation/screens/payslip_list_screen.dart';
import '../features/payroll/presentation/screens/payslip_detail_screen.dart';
import '../features/calendar/presentation/screens/company_calendar_screen.dart';
import '../features/calendar/presentation/screens/event_detail_screen.dart';
import '../features/calendar/presentation/screens/announcements_screen.dart';
import '../features/calendar/presentation/screens/announcement_detail_screen.dart';

// Profile, Settings, Notifications, Directory, Face Update
import '../features/profile/presentation/screens/user_profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart';
import '../features/profile/presentation/screens/help_support_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/company_directory_screen.dart';
import '../features/profile/presentation/screens/face_update_screen.dart';

// Overtime
import '../features/overtime/presentation/screens/overtime_list_screen.dart';
import '../features/overtime/presentation/screens/overtime_form_screen.dart';
import '../features/overtime/presentation/screens/overtime_detail_screen.dart';

// Admin & Manager
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/admin/presentation/screens/manager_dashboard_screen.dart';
import '../features/admin/presentation/screens/hr_employee_dashboard_screen.dart';
import '../features/admin/presentation/screens/employee_management_screen.dart';
import '../features/admin/presentation/screens/employee_detail_admin_screen.dart';
import '../features/admin/presentation/screens/employee_onboarding_admin_screen.dart';
import '../features/admin/presentation/screens/employee_edit_admin_screen.dart';
import '../features/admin/presentation/screens/attendance_report_admin_screen.dart';
import '../features/admin/presentation/screens/attendance_flag_review_screen.dart';
import '../features/admin/presentation/screens/leave_request_admin_screen.dart';
import '../features/admin/presentation/screens/claim_detail_admin_screen.dart';
import '../features/admin/presentation/screens/team_approvals_screen.dart';
import '../features/admin/presentation/screens/team_performance_screen.dart';
import '../features/admin/presentation/screens/payroll_configuration_screen.dart';
import '../features/admin/presentation/screens/payroll_run_list_screen.dart';
import '../features/admin/presentation/screens/payroll_run_detail_screen.dart';
import '../features/admin/presentation/screens/shift_templates_screen.dart';
import '../features/admin/presentation/screens/shift_template_form_screen.dart';
import '../features/admin/presentation/screens/shift_assignment_grid_screen.dart';
import '../features/admin/presentation/screens/create_announcement_screen.dart';
import '../features/admin/presentation/screens/organization_settings_screen.dart';
import '../features/admin/presentation/screens/department_analytics_screen.dart';
import '../features/admin/presentation/screens/export_center_screen.dart';
import '../features/admin/presentation/screens/audit_logs_screen.dart';
import '../features/admin/presentation/screens/admin_settings_screen.dart';
import '../features/admin/presentation/screens/company_events_manager_screen.dart';
import '../features/admin/presentation/screens/event_edit_admin_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/otp', builder: (_, __) => const OtpScreen()),
    GoRoute(
        path: '/device-binding',
        builder: (_, __) => const DeviceBindingScreen()),
    GoRoute(
        path: '/face-enrollment',
        builder: (_, __) => const FaceEnrollmentScreen()),
    GoRoute(path: '/app/tour', builder: (_, __) => const AppTourGuideScreen()),

    // Independent full-screen routes (no bottom nav)
    GoRoute(
        path: '/app/attendance/check-in',
        builder: (_, __) => const FaceCheckInScreen()),
    GoRoute(
        path: '/app/attendance/success',
        builder: (_, __) => const CheckInSuccessScreen()),
    GoRoute(
        path: '/app/attendance/detail',
        builder: (_, __) => const AttendanceDetailScreen()),
    GoRoute(
        path: '/app/attendance/report',
        builder: (_, __) => const AttendanceReportScreen()),
    GoRoute(
        path: '/app/attendance/dispute',
        builder: (_, __) => const AttendanceDisputeScreen()),

    GoRoute(
        path: '/app/schedule/shifts',
        builder: (_, __) => const ShiftScheduleScreen()),
    GoRoute(
        path: '/app/habits', builder: (_, __) => const HabitTrackerScreen()),
    GoRoute(
        path: '/app/habits/new', builder: (_, __) => const HabitFormScreen()),
    GoRoute(
        path: '/app/habits/detail',
        builder: (_, __) => const HabitDetailScreen()),

    GoRoute(
        path: '/app/leave/new',
        builder: (_, __) => const LeaveRequestFormScreen()),
    GoRoute(
        path: '/app/leave/detail',
        builder: (_, __) => const LeaveDetailScreen()),
    GoRoute(
        path: '/app/leave/approval-detail',
        builder: (_, __) => const ApprovalDetailScreen()),

    GoRoute(path: '/app/claims', builder: (_, __) => const ClaimListScreen()),
    GoRoute(
        path: '/app/claims/new',
        builder: (_, __) => const ClaimSubmissionScreen()),
    GoRoute(
        path: '/app/claims/detail',
        builder: (_, __) => const ClaimDetailScreen()),

    GoRoute(
        path: '/app/payslip', builder: (_, __) => const PayslipListScreen()),
    GoRoute(
        path: '/app/payslip/detail',
        builder: (_, __) => const PayslipDetailScreen()),

    GoRoute(
        path: '/app/calendar',
        builder: (_, __) => const CompanyCalendarScreen()),
    GoRoute(
        path: '/app/calendar/event',
        builder: (_, __) => const EventDetailScreen()),
    GoRoute(
        path: '/app/announcements',
        builder: (_, __) => const AnnouncementsScreen()),
    GoRoute(
        path: '/app/announcements/detail',
        builder: (_, __) => const AnnouncementDetailScreen()),

    GoRoute(
        path: '/app/notifications',
        builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: '/app/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/app/help', builder: (_, __) => const HelpSupportScreen()),
    GoRoute(
        path: '/app/profile/edit',
        builder: (_, __) => const EditProfileScreen()),
    GoRoute(
        path: '/app/profile/face-update',
        builder: (_, __) => const FaceUpdateScreen()),
    GoRoute(
        path: '/app/directory',
        builder: (_, __) => const CompanyDirectoryScreen()),

    // Overtime
    GoRoute(
        path: '/app/overtime', builder: (_, __) => const OvertimeListScreen()),
    GoRoute(
        path: '/app/overtime/new',
        builder: (_, __) => const OvertimeFormScreen()),
    GoRoute(
        path: '/app/overtime/detail',
        builder: (_, __) => const OvertimeDetailScreen()),

    // Admin & Manager routes
    GoRoute(
        path: '/admin/dashboard',
        builder: (_, __) => const AdminDashboardScreen()),
    GoRoute(
        path: '/manager/dashboard',
        builder: (_, __) => const ManagerDashboardScreen()),
    GoRoute(
        path: '/admin/hr-dashboard',
        builder: (_, __) => const HREmployeeDashboardScreen()),
    GoRoute(
        path: '/admin/employees',
        builder: (_, __) => const EmployeeManagementScreen()),
    GoRoute(
      path: '/admin/employees/detail',
      builder: (_, state) {
        final employee = state.extra as Map<String, dynamic>? ?? {};
        return EmployeeDetailAdminScreen(employee: employee);
      },
    ),
    GoRoute(
      path: '/admin/employees/edit',
      builder: (_, state) {
        final employee = state.extra as Map<String, dynamic>? ?? {};
        return EmployeeEditAdminScreen(employee: employee);
      },
    ),
    GoRoute(
        path: '/admin/employees/onboarding',
        builder: (_, __) => const EmployeeOnboardingAdminScreen()),
    GoRoute(
        path: '/admin/reports',
        builder: (_, __) => const AttendanceReportAdminScreen()),
    GoRoute(
        path: '/admin/attendance-flags',
        builder: (_, __) => const AttendanceFlagReviewScreen()),
    GoRoute(
        path: '/admin/approvals',
        builder: (_, __) =>
            const LeaveRequestAdminScreen()), // Using LeaveRequestAdminScreen for generic admin approval demo
    GoRoute(
        path: '/admin/claims',
        builder: (_, __) => const ClaimDetailAdminScreen()),
    GoRoute(
        path: '/manager/approvals',
        builder: (_, __) => const TeamApprovalsScreen()),
    GoRoute(
        path: '/manager/team-performance',
        builder: (_, __) => const TeamPerformanceScreen()),
    GoRoute(
        path: '/admin/payroll-config',
        builder: (_, __) => const PayrollConfigurationScreen()),
    GoRoute(
        path: '/admin/payroll',
        builder: (_, __) => const PayrollRunListScreen()),
    GoRoute(
        path: '/admin/payroll/detail',
        builder: (_, state) {
          final runId = state.extra as int;
          return PayrollRunDetailScreen(runId: runId);
        }),
    GoRoute(
        path: '/admin/shifts',
        builder: (_, __) =>
            const ShiftTemplatesScreen()), // Using this as entry point for shifts for now
    GoRoute(
        path: '/admin/shifts/form',
        builder: (_, state) {
          final template = state.extra as Map<String, dynamic>?;
          return ShiftTemplateFormScreen(template: template);
        }),
    GoRoute(
        path: '/admin/shift-assignments',
        builder: (_, __) => const ShiftAssignmentGridScreen()),
    GoRoute(
        path: '/admin/announcements/new',
        builder: (_, __) => const CreateAnnouncementScreen()),
    GoRoute(
        path: '/admin/org-settings',
        builder: (_, __) => const OrganizationSettingsScreen()),
    GoRoute(
        path: '/admin/department-analytics',
        builder: (_, __) => const DepartmentAnalyticsScreen()),
    GoRoute(
        path: '/admin/export', builder: (_, __) => const ExportCenterScreen()),
    GoRoute(
        path: '/admin/audit-logs', builder: (_, __) => const AuditLogsScreen()),
    GoRoute(
        path: '/admin/settings',
        builder: (_, __) => const AdminSettingsScreen()),
    GoRoute(
        path: '/admin/events',
        builder: (_, __) => const CompanyEventsManagerScreen()),
    GoRoute(
        path: '/admin/events/edit',
        builder: (_, state) {
          final event = state.extra as CalendarEventModel?;
          return EventEditAdminScreen(event: event);
        }),

    // Main Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          BottomNavShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/app/home',
              builder: (_, __) => const HomeDashboardScreen())
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/app/attendance',
              builder: (_, __) => const AttendanceHistoryScreen())
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/app/leave',
              builder: (_, __) => const ApprovalInboxScreen())
        ]), // Swapped to Inbox for better default manager feel, but could be LeaveRequestsScreen. Let's use ApprovalInboxScreen
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/app/profile',
              builder: (_, __) => const UserProfileScreen())
        ]),
      ],
    ),
  ],
);
