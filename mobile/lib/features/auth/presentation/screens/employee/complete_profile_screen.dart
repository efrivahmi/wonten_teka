import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/repositories/auth_repository.dart';
import '../../../bloc/auth_bloc.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _nikController = TextEditingController();
  final _npwpController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _joinDateController = TextEditingController();
  final _bpjsKesController = TextEditingController();
  final _bpjsKetController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankHolderController = TextEditingController();

  String? _gender;
  String? _employmentStatus;
  String? _ptkpStatus;
  String? _bankName;
  String? _department;
  String? _position;

  bool _isLoadingOptions = true;
  List<String> _departments = [];
  List<String> _positions = [];

  final List<String> _popularBanks = [
    'BCA', 'Mandiri', 'BNI', 'BRI', 'BSI', 'CIMB Niaga', 'Permata', 'Danamon', 'Mega', 'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      _fullNameController.text = user.name;
      _emailController.text = user.email;
      
      final emp = user.employee;
      if (emp != null) {
        if (emp.fullName.isNotEmpty) _fullNameController.text = emp.fullName;
        if (emp.phone != null) _phoneController.text = emp.phone!;
        if (emp.address != null) _addressController.text = emp.address!;
        if (emp.department != null) _department = emp.department;
        if (emp.position != null) _position = emp.position;
        if (emp.gender != null) _gender = emp.gender;
        if (emp.joinDate != null) {
          _joinDateController.text = emp.joinDate!.toIso8601String().split('T')[0];
        }
      }
    }

    _fetchOptions();
    if (_addressController.text.isEmpty) {
      _fetchLocationAndAddress();
    }
  }

  Future<void> _fetchLocationAndAddress() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        
        if (mounted) {
          setState(() {
            _addressController.text = address;
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal mendapatkan lokasi: $e");
    }
  }

  Future<void> _fetchOptions() async {
    try {
      final repo = context.read<AuthRepository>();
      final options = await repo.getEmployeeOptions();
      if (mounted) {
        setState(() {
          _departments = (options['departments'] as List).map((e) => e.toString()).toList();
          _positions = (options['positions'] as List).map((e) => e.toString()).toList();
          if (_departments.isEmpty) _departments = ['HR', 'IT', 'Finance', 'Marketing', 'Lainnya'];
          if (_positions.isEmpty) _positions = ['Staff', 'Lainnya'];
          _isLoadingOptions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _departments = ['HR', 'IT', 'Finance', 'Marketing', 'Lainnya'];
          _positions = ['Staff', 'Lainnya'];
          _isLoadingOptions = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nikController.dispose();
    _npwpController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _joinDateController.dispose();
    _bpjsKesController.dispose();
    _bpjsKetController.dispose();
    _bankAccountController.dispose();
    _bankHolderController.dispose();
    super.dispose();
  }

  void _submitProfile() {
    if (_formKey.currentState!.validate()) {
      final profileData = {
        'full_name': _fullNameController.text,
        'nik': _nikController.text,
        'npwp': _npwpController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'date_of_birth': _dobController.text,
        'gender': _gender,
        'address': _addressController.text,
        'department': _department,
        'position': _position,
        'join_date': _joinDateController.text,
        'employment_status': _employmentStatus,
        'ptkp_status': _ptkpStatus,
        'bpjs_kesehatan_number': _bpjsKesController.text,
        'bpjs_ketenagakerjaan_number': _bpjsKetController.text,
        'bank_name': _bankName,
        'bank_account_number': _bankAccountController.text,
        'bank_account_holder': _bankHolderController.text,
      };

      context.read<AuthBloc>().add(AuthCompleteProfileRequested(profileData));
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Complete Profile'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: _isLoadingOptions
          ? const Center(child: CircularProgressIndicator())
          : BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  if (state.user.employee != null) {
                    if (state.user.employee!.faceEnrolled) {
                      context.go('/app');
                    } else {
                      context.go('/face-enrollment');
                    }
                  }
                } else if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                return Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(24.w),
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.successEmerald.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.successEmerald.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.security, color: AppColors.successEmerald),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Data sensitif seperti NIK, NPWP, BPJS, dan Rekening diproses menggunakan enkripsi di server kami untuk menjamin keamanan Anda.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.successEmerald),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Selamat datang! Silakan lengkapi profil karyawan Anda.',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 24.h),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap*'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Alamat Email*'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _nikController,
                        decoration: const InputDecoration(labelText: 'NIK KTP'),
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _npwpController,
                        decoration: const InputDecoration(labelText: 'Nomor NPWP'),
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        onTap: () => _selectDate(_dobController),
                        decoration: const InputDecoration(labelText: 'Tanggal Lahir (YYYY-MM-DD)'),
                      ),
                      SizedBox(height: 16.h),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                        initialValue: _gender,
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                          DropdownMenuItem(value: 'female', child: Text('Perempuan')),
                        ],
                        onChanged: (v) => setState(() => _gender = v),
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Alamat Domisili',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.my_location),
                            onPressed: _fetchLocationAndAddress,
                            tooltip: 'Get Current Location',
                          ),
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 16.h),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Departemen'),
                        initialValue: _department,
                        items: _departments.map((dep) => DropdownMenuItem(value: dep, child: Text(dep))).toList(),
                        onChanged: (v) => setState(() => _department = v),
                      ),
                      SizedBox(height: 16.h),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Posisi / Jabatan'),
                        initialValue: _position,
                        items: _positions.map((pos) => DropdownMenuItem(value: pos, child: Text(pos))).toList(),
                        onChanged: (v) => setState(() => _position = v),
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _joinDateController,
                        readOnly: true,
                        onTap: () => _selectDate(_joinDateController),
                        decoration: const InputDecoration(labelText: 'Tanggal Bergabung (YYYY-MM-DD)'),
                      ),
                      SizedBox(height: 16.h),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Status Kepegawaian*'),
                        initialValue: _employmentStatus,
                        items: const [
                          DropdownMenuItem(value: 'permanent', child: Text('Karyawan Tetap')),
                          DropdownMenuItem(value: 'contract', child: Text('Karyawan Kontrak')),
                          DropdownMenuItem(value: 'probation', child: Text('Masa Percobaan')),
                          DropdownMenuItem(value: 'intern', child: Text('Magang')),
                        ],
                        validator: (v) => v == null || v.isEmpty ? 'Pilih status' : null,
                        onChanged: (v) => setState(() => _employmentStatus = v),
                      ),
                      SizedBox(height: 16.h),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Status PTKP*'),
                        initialValue: _ptkpStatus,
                        items: const [
                          DropdownMenuItem(value: 'TK/0', child: Text('TK/0 - Tidak Kawin, 0 Tanggungan')),
                          DropdownMenuItem(value: 'TK/1', child: Text('TK/1 - Tidak Kawin, 1 Tanggungan')),
                          DropdownMenuItem(value: 'TK/2', child: Text('TK/2 - Tidak Kawin, 2 Tanggungan')),
                          DropdownMenuItem(value: 'TK/3', child: Text('TK/3 - Tidak Kawin, 3 Tanggungan')),
                          DropdownMenuItem(value: 'K/0', child: Text('K/0 - Kawin, 0 Tanggungan')),
                          DropdownMenuItem(value: 'K/1', child: Text('K/1 - Kawin, 1 Tanggungan')),
                          DropdownMenuItem(value: 'K/2', child: Text('K/2 - Kawin, 2 Tanggungan')),
                          DropdownMenuItem(value: 'K/3', child: Text('K/3 - Kawin, 3 Tanggungan')),
                          DropdownMenuItem(value: 'K/I/0', child: Text('K/I/0 - Kawin (Istri Bekerja), 0 Tanggungan')),
                          DropdownMenuItem(value: 'K/I/1', child: Text('K/I/1 - Kawin (Istri Bekerja), 1 Tanggungan')),
                          DropdownMenuItem(value: 'K/I/2', child: Text('K/I/2 - Kawin (Istri Bekerja), 2 Tanggungan')),
                          DropdownMenuItem(value: 'K/I/3', child: Text('K/I/3 - Kawin (Istri Bekerja), 3 Tanggungan')),
                        ],
                        validator: (v) => v == null || v.isEmpty ? 'Pilih status PTKP' : null,
                        onChanged: (v) => setState(() => _ptkpStatus = v),
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _bpjsKesController,
                        decoration: const InputDecoration(labelText: 'Nomor BPJS Kesehatan'),
                        keyboardType: TextInputType.number,
                        maxLength: 13,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _bpjsKetController,
                        decoration: const InputDecoration(labelText: 'Nomor BPJS Ketenagakerjaan'),
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      SizedBox(height: 16.h),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Nama Bank'),
                        initialValue: _bankName,
                        items: _popularBanks.map((bank) => DropdownMenuItem(value: bank, child: Text(bank))).toList(),
                        onChanged: (v) => setState(() => _bankName = v),
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _bankAccountController,
                        decoration: const InputDecoration(labelText: 'Nomor Rekening Bank'),
                        keyboardType: TextInputType.number,
                        maxLength: 20,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _bankHolderController,
                        decoration: const InputDecoration(labelText: 'Nama Pemilik Rekening'),
                      ),
                      SizedBox(height: 32.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: FilledButton(
                          onPressed: state is AuthLoading ? null : _submitProfile,
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Lengkapi Profil'),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
