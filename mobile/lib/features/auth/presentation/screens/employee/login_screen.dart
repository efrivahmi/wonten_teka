import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../../../core/widgets/wonten_card.dart';
import '../../../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyIdController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _companyIdController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      TextInput.finishAutofillContext();
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _usernameController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            left: 12.w,
            right: 12.w,
            top: 12.h,
            child: BrandPanel(child: SizedBox(height: 260.h)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 40.h),
                      ViewEntrance(
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.r)),
                                child: Image.asset(
                                    'assets/images/e-absensi-logo-generated.png',
                                    height: 48.h,
                                    fit: BoxFit.contain),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'e-Absensi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Lemdiklat Taruna Nusantara Indonesia',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 14.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 7.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(99.r),
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: .2)),
                                ),
                                child: Text(
                                  'SISTEM KEHADIRAN TERPADU',
                                  style: TextStyle(
                                    color: AppColors.primaryFixed,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),
                      ViewEntrance(
                        delay: const Duration(milliseconds: 120),
                        child: WontenCard(
                          padding: EdgeInsets.all(26.w),
                          child: Form(
                            key: _formKey,
                            child: AutofillGroup(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Masuk ke ruang kerja',
                                    style: TextStyle(
                                      color: AppColors.onSurface,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(height: 7.h),
                                  Text(
                                    'Kelola kehadiran dan aktivitas kerja Anda.',
                                    style: TextStyle(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  Text(
                                    'EMAIL / NIP',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  TextFormField(
                                    controller: _usernameController,
                                    enabled: !isLoading,
                                    autofillHints: const [
                                      AutofillHints.username,
                                      AutofillHints.email
                                    ],
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                          Icons.person_outline,
                                          color: AppColors.primary),
                                      hintText: 'Masukkan email atau NIP',
                                      filled: true,
                                      fillColor: AppColors.surfaceContainerLow,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 16.h),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(14.r),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(14.r),
                                        borderSide: const BorderSide(
                                            color: AppColors.outlineVariant),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(14.r),
                                        borderSide: const BorderSide(
                                            color: AppColors.primary),
                                      ),
                                    ),
                                    validator: (value) => value?.isEmpty ?? true
                                        ? 'Wajib diisi'
                                        : null,
                                  ),
                                  SizedBox(height: 20.h),
                                  Text(
                                    'PASSWORD',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    enabled: !isLoading,
                                    autofillHints: const [
                                      AutofillHints.password
                                    ],
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) {
                                      if (!isLoading) _handleLogin();
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.lock_outline,
                                          color: AppColors.primary),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey[500],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      hintText: 'Masukkan Password',
                                      filled: true,
                                      fillColor: AppColors.surfaceContainerLow,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 16.h),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(14.r),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(14.r),
                                        borderSide: const BorderSide(
                                            color: AppColors.outlineVariant),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(14.r),
                                        borderSide: const BorderSide(
                                            color: AppColors.primary),
                                      ),
                                    ),
                                    validator: (value) => value?.isEmpty ?? true
                                        ? 'Wajib diisi'
                                        : null,
                                  ),
                                  SizedBox(height: 12.h),
                                  SizedBox(height: 24.h),
                                  SizedBox(
                                    height: 56.h,
                                    child: FilledButton(
                                      onPressed:
                                          isLoading ? null : _handleLogin,
                                      child: isLoading
                                          ? SizedBox(
                                              height: 24.w,
                                              width: 24.w,
                                              child:
                                                  const CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2))
                                          : Text(
                                              'Masuk',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 22.h),
                      Text(
                        'Akses aman untuk karyawan dan administrator',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11.sp,
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
