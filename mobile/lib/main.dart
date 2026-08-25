import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/api/api_client.dart';
import 'core/storage/secure_storage.dart';
import 'core/repositories/auth_repository.dart';
import 'core/repositories/attendance_repository.dart';
import 'core/repositories/leave_repository.dart';
import 'core/repositories/approval_repository.dart';
import 'core/repositories/claim_repository.dart';
import 'core/repositories/payslip_repository.dart';
import 'core/repositories/shift_repository.dart';
import 'core/repositories/company_repository.dart';
import 'core/repositories/task_repository.dart';
import 'core/repositories/device_repository.dart';
import 'core/repositories/device_admin_repository.dart';

import 'features/auth/bloc/auth_bloc.dart';
import 'features/attendance/bloc/attendance_cubit.dart';
import 'features/leave/bloc/leave_cubit.dart';
import 'features/approval/bloc/approval_cubit.dart';
import 'features/claims/bloc/claim_cubit.dart';
import 'features/payroll/bloc/payslip_cubit.dart';
import 'features/schedule/bloc/shift_cubit.dart';
import 'features/company/bloc/company_cubit.dart';
import 'features/schedule/bloc/task_cubit.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize locale data for date formatting (prevents LocaleDataException)
  await initializeDateFormatting('id_ID', null);
  
  final secureStorage = SecureStorage();
  final apiClient = ApiClient(storage: secureStorage);

  runApp(WontenTekaApp(
    apiClient: apiClient,
    secureStorage: secureStorage,
  ));
}

class WontenTekaApp extends StatelessWidget {
  final ApiClient apiClient;
  final SecureStorage secureStorage;

  const WontenTekaApp({
    super.key,
    required this.apiClient,
    required this.secureStorage,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider(create: (_) => AuthRepository(api: apiClient, storage: secureStorage)),
        RepositoryProvider(create: (_) => AttendanceRepository(api: apiClient)),
        RepositoryProvider(create: (_) => LeaveRepository(api: apiClient)),
        RepositoryProvider(create: (_) => ApprovalRepository(api: apiClient)),
        RepositoryProvider(create: (_) => ClaimRepository(api: apiClient)),
        RepositoryProvider(create: (_) => PayslipRepository(api: apiClient)),
        RepositoryProvider(create: (_) => ShiftRepository(api: apiClient)),
        RepositoryProvider(create: (_) => CompanyRepository(api: apiClient)),
        RepositoryProvider(create: (_) => TaskRepository(api: apiClient)),
        RepositoryProvider(create: (_) => DeviceRepository(api: apiClient)),
        RepositoryProvider(create: (_) => DeviceAdminRepository(api: apiClient)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(authRepository: context.read<AuthRepository>())
              ..add(AuthCheckSession()),
          ),
          BlocProvider(create: (context) => AttendanceCubit(repository: context.read<AttendanceRepository>())),
          BlocProvider(create: (context) => LeaveCubit(repository: context.read<LeaveRepository>())),
          BlocProvider(create: (context) => ApprovalCubit(repository: context.read<ApprovalRepository>())),
          BlocProvider(create: (context) => ClaimCubit(repository: context.read<ClaimRepository>())),
          BlocProvider(create: (context) => PayslipCubit(repository: context.read<PayslipRepository>())),
          BlocProvider(create: (context) => ShiftCubit(repository: context.read<ShiftRepository>())),
          BlocProvider(create: (context) => CompanyCubit(repository: context.read<CompanyRepository>())),
          BlocProvider(create: (context) => TaskCubit(repository: context.read<TaskRepository>())),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state is AuthUnauthenticated) {
              appRouter.go('/login');
            } else if (state is AuthAuthenticated) {
              try {
                // 0. Force Device Binding Check via Backend
                final deviceRepo = context.read<DeviceRepository>();
                final storage = SecureStorage();
                final fingerprint = await storage.getDeviceFingerprint();
                
                if (fingerprint == null) {
                   appRouter.go('/device-binding');
                   return;
                }
                
                try {
                  final device = await deviceRepo.getStatus(fingerprint);
                  final status = device.status;
                  
                  if (status == 'pending_approval') {
                     appRouter.go('/device-pending');
                     return;
                  } else if (status != 'active') {
                     appRouter.go('/device-binding');
                     return;
                  }
                } catch (e) {
                  // e.g. 404 if device not found
                  appRouter.go('/device-binding');
                  return;
                }

                // 1. Force Face Enrollment Check
                final isFaceEnrolled = state.user.employee?.faceEnrolled ?? false;
                if (!isFaceEnrolled) {
                  appRouter.go('/face-enrollment');
                  return;
                }

                // Fire-and-forget sync of face data for offline/fast recognition
                context.read<AttendanceCubit>().syncFaceData();

                // 2. Role-based Dashboard Routing
                if (state.user.isAdmin) {
                  appRouter.go('/admin/dashboard');
                } else if (state.user.isManager) {
                  appRouter.go('/manager/dashboard');
                } else {
                  appRouter.go('/app/home');
                }
              } catch (e) {
                // If anything fails during routing checks, go to device binding as safe default
                appRouter.go('/device-binding');
              }
            }
          },
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp.router(
                title: 'Wonten Teka',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                routerConfig: appRouter,
              );
            },
          ),
        ),
      ),
    );
  }
}
