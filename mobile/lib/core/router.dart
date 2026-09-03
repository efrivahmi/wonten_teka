import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/bottom_nav_shell.dart';

// Models
import 'models/company_models.dart';
import 'models/attendance_log_model.dart';
import 'models/payslip_model.dart';
import 'models/leave_models.dart';

// Pre-auth
import '../features/onboarding/presentation/screens/employee/splash_screen.dart';
import '../features/onboarding/presentation/screens/employee/onboarding_screen.dart';
import '../features/auth/presentation/screens/employee/login_screen.dart';
import '../features/auth/presentation/screens/employee/otp_screen.dart';
import '../features/auth/presentation/screens/employee/device_binding_screen.dart';
import '../features/auth/presentation/screens/employee/device_pending_screen.dart';
import '../features/auth/presentation/screens/employee/complete_profile_screen.dart';
import '../features/attendance/presentation/screens/employee/face_enrollment_screen.dart';
import '../features/onboarding/presentation/screens/employee/app_tour_guide_screen.dart';

// Main Navigation Shell
// Dashboard & Attendance
import '../features/dashboard/presentation/screens/employee/home_dashboard_screen.dart';
import '../features/dashboard/presentation/screens/employee/all_features_screen.dart';
import '../features/attendance/presentation/screens/employee/attendance_history_screen.dart';
import '../features/attendance/presentation/screens/employee/face_check_in_screen.dart';
import '../features/attendance/presentation/screens/employee/check_in_success_screen.dart';
import '../features/attendance/presentation/screens/employee/attendance_detail_screen.dart';
import '../features/attendance/presentation/screens/attendance_report_screen.dart';
import '../features/attendance/presentation/screens/employee/attendance_dispute_screen.dart';
import '../features/attendance/presentation/screens/employee/attendance_adjustment_form_screen.dart';
import '../features/attendance/presentation/screens/employee/business_trip_form_screen.dart';

// Schedule & Habits
import '../features/schedule/presentation/screens/employee/shift_schedule_screen.dart';
import '../features/schedule_habit/presentation/screens/employee/habit_tracker_screen.dart';
import '../features/schedule_habit/presentation/screens/employee/habit_form_screen.dart';
import '../features/schedule_habit/presentation/screens/employee/habit_detail_screen.dart';

// Leave, Approval, & Claims
import '../features/leave/presentation/screens/employee/leave_history_screen.dart';
import '../features/leave/presentation/screens/employee/leave_request_form_screen.dart';
import '../features/leave/presentation/screens/employee/leave_detail_screen.dart';
import '../features/approval/presentation/screens/manager/approval_inbox_screen.dart';
import '../features/approval/presentation/screens/manager/approval_detail_screen.dart';
import '../features/claims/presentation/screens/employee/claim_list_screen.dart';
import '../features/claims/presentation/screens/employee/claim_submission_screen.dart';
import '../features/claims/presentation/screens/employee/claim_detail_screen.dart';

// Payroll, Calendar, Announcements
import '../features/payroll/presentation/screens/employee/payslip_list_screen.dart';
import '../features/payroll/presentation/screens/employee/payslip_detail_screen.dart';
import '../features/calendar/presentation/screens/employee/company_calendar_screen.dart';
import '../features/calendar/presentation/screens/employee/event_detail_screen.dart';
import '../features/calendar/presentation/screens/employee/announcements_screen.dart';
import '../features/calendar/presentation/screens/employee/announcement_detail_screen.dart';

// Profile, Settings, Notifications, Directory, Face Update
import '../features/profile/presentation/screens/employee/user_profile_screen.dart';
import '../features/profile/presentation/screens/employee/edit_profile_screen.dart';
import '../features/profile/presentation/screens/employee/settings_screen.dart';
import '../features/profile/presentation/screens/employee/help_support_screen.dart';
import '../features/notifications/presentation/screens/employee/notifications_screen.dart';
import '../features/profile/presentation/screens/employee/company_directory_screen.dart';
import '../features/profile/presentation/screens/employee/face_update_screen.dart';

// Overtime
import '../features/overtime/presentation/screens/employee/overtime_list_screen.dart';
import '../features/overtime/presentation/screens/employee/overtime_form_screen.dart';
import '../features/overtime/presentation/screens/employee/overtime_detail_screen.dart';

// Admin 
import '../features/dashboard/presentation/screens/admin/admin_dashboard_screen.dart';
import '../features/company/presentation/screens/admin/employee_management_screen.dart';
import '../features/company/presentation/screens/admin/employee_detail_admin_screen.dart';
import '../features/company/presentation/screens/admin/employee_onboarding_admin_screen.dart';
import '../features/company/presentation/screens/admin/employee_edit_admin_screen.dart';
import '../features/attendance/presentation/screens/admin/attendance_report_admin_screen.dart';
import '../features/attendance/presentation/screens/admin/attendance_flag_review_screen.dart';
import '../features/attendance/presentation/screens/admin/daily_attendance_table_screen.dart';

import '../features/claims/presentation/screens/admin/claim_detail_admin_screen.dart';
import '../features/payroll/presentation/screens/admin/payroll_configuration_screen.dart';
import '../features/payroll/presentation/screens/admin/payroll_run_list_screen.dart';
import '../features/payroll/presentation/screens/admin/payroll_run_detail_screen.dart';
import '../features/schedule/presentation/screens/admin/shift_templates_screen.dart';
import '../features/schedule/presentation/screens/admin/shift_template_form_screen.dart';
import '../features/schedule/presentation/screens/admin/shift_assignment_grid_screen.dart';
import '../features/leave/presentation/screens/admin/leave_types_admin_screen.dart';
import '../features/leave/presentation/screens/admin/leave_type_form_screen.dart';
import '../features/calendar/presentation/screens/admin/create_announcement_screen.dart';
import '../features/company/presentation/screens/admin/organization_settings_screen.dart';

import '../features/company/presentation/screens/admin/department_analytics_screen.dart';
import '../features/company/presentation/screens/admin/export_center_screen.dart';
import '../features/company/presentation/screens/admin/audit_logs_screen.dart';
import '../features/company/presentation/screens/admin/admin_settings_screen.dart';
import '../features/calendar/presentation/screens/admin/company_events_manager_screen.dart';
import '../features/calendar/presentation/screens/admin/event_edit_admin_screen.dart';
import '../features/auth/presentation/screens/admin/device_approval_admin_screen.dart';

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
        path: '/device-pending',
        builder: (_, __) => const DevicePendingScreen()),
    GoRoute(
        path: '/face-enrollment',
        builder: (_, __) => const FaceEnrollmentScreen()),
    GoRoute(
        path: '/complete-profile',
        builder: (_, __) => const CompleteProfileScreen()),
    GoRoute(path: '/app/tour', builder: (_, __) => const AppTourGuideScreen()),

    // Independent full-screen routes (no bottom nav)
      GoRoute(
          path: '/app/attendance/check-in',
          builder: (_, __) => const FaceCheckInScreen()),
      GoRoute(
          path: '/app/attendance/check-out',
          builder: (_, __) => const FaceCheckInScreen(isCheckOut: true)),
      GoRoute(
          path: '/app/attendance/success',
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final log = extra['log'] as AttendanceLogModel;
            final isCheckOut = extra['isCheckOut'] as bool? ?? false;
            return CheckInSuccessScreen(log: log, isCheckOut: isCheckOut);
          }),
      GoRoute(
        path: '/app/attendance/adjustment-form',
        builder: (_, __) => const AttendanceAdjustmentFormScreen()),
      GoRoute(
        path: '/app/attendance/business-trip-form',
        builder: (_, __) => const BusinessTripFormScreen()),
    GoRoute(
        path: '/app/attendance/detail',
        builder: (_, state) {
          final log = state.extra as AttendanceLogModel?;
          if (log == null) return const AttendanceHistoryScreen();
          return AttendanceDetailScreen(log: log);
        }),
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
        path: '/app/leave',
        builder: (_, __) => const LeaveHistoryScreen()),
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
        builder: (_, state) {
          final payslip = state.extra as PayslipModel?;
          if (payslip == null) return const PayslipListScreen();
          return PayslipDetailScreen(payslip: payslip);
        }),

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

    // Admin routes
    GoRoute(
        path: '/admin/dashboard',
        builder: (_, __) => const AdminDashboardScreen()),
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
        path: '/admin/attendance-daily',
        builder: (_, __) => const DailyAttendanceTableScreen()),
      GoRoute(
        path: '/admin/attendance-flags',
        builder: (_, __) => const AttendanceFlagReviewScreen()),
    GoRoute(
        path: '/admin/approvals',
        builder: (_, __) => const ApprovalInboxScreen()),
    GoRoute(
        path: '/admin/claims',
        builder: (_, __) => const ClaimDetailAdminScreen()),
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
        path: '/admin/leave-types',
        builder: (_, __) => const LeaveTypesAdminScreen()),
    GoRoute(
        path: '/admin/leave-types/form',
        builder: (_, state) {
          final leaveType = state.extra as LeaveTypeModel?;
          return LeaveTypeFormScreen(leaveType: leaveType);
        }),
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
    GoRoute(
        path: '/admin/devices',
        builder: (_, __) => const DeviceApprovalAdminScreen()),

    // Main features (tabs)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BottomNavShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/app/home',
              builder: (context, state) => const HomeDashboardScreen(),
            ),
            GoRoute(
              path: '/app/all-features',
              builder: (context, state) => const AllFeaturesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
                path: '/app/attendance',
                builder: (_, __) => const AttendanceHistoryScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
                path: '/app/payroll',
                builder: (_, __) => const PayslipListScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
                path: '/app/profile',
                builder: (_, __) => const UserProfileScreen()),
          ],
        ),
      ],
    ),
  ],
);


