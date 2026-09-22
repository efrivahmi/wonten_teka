import 'package:flutter/material.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';
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
  final _bpjsTkController = TextEditingController();
  final _ptkpController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountController = TextEditingController();

  String? _gender;
  String? _employmentStatus;
  String? _department;
  String? _position;

  bool _isLoadingOptions = true;
  List<String> _departments = [];
  List<String> _positions = [];
  List<Map<String, String>> _genders = [];
  List<Map<String, String>> _employmentStatuses = [];
  String? _optionsError;

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
          _joinDateController.text =
              emp.joinDate!.toIso8601String().split('T')[0];
        }
        if (emp.nik != null) _nikController.text = emp.nik!;
        if (emp.npwp != null) _npwpController.text = emp.npwp!;
        if (emp.dateOfBirth != null) {
          _dobController.text =
              emp.dateOfBirth!.toIso8601String().split('T')[0];
        }
        if (emp.employmentStatus != null) {
          _employmentStatus = emp.employmentStatus;
        }
        if (emp.bpjsKesehatan != null) {
          _bpjsKesController.text = emp.bpjsKesehatan!;
        }
        if (emp.bpjsKetenagakerjaan != null) {
          _bpjsTkController.text = emp.bpjsKetenagakerjaan!;
        }
        if (emp.ptkpStatus != null) _ptkpController.text = emp.ptkpStatus!;
        if (emp.bankName != null) _bankNameController.text = emp.bankName!;
        if (emp.bankAccount != null) {
          _bankAccountController.text = emp.bankAccount!;
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
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
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
          _departments = (options['departments'] as List)
              .map((e) => e.toString())
              .toList();
          _positions =
              (options['positions'] as List).map((e) => e.toString()).toList();
          _genders = _optionMaps(options['genders']);
          _employmentStatuses = _optionMaps(options['employment_statuses']);
          _optionsError = null;
          _isLoadingOptions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _optionsError =
              'Data pilihan gagal dimuat. Periksa koneksi lalu coba lagi.';
          _isLoadingOptions = false;
        });
      }
    }
  }

  List<Map<String, String>> _optionMaps(dynamic raw) => (raw as List? ?? [])
      .whereType<Map>()
      .map((item) => {
            'value': item['value'].toString(),
            'label': item['label'].toString(),
          })
      .toList();

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
    _bpjsTkController.dispose();
    _ptkpController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
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
        'bpjs_kesehatan_number': _bpjsKesController.text,
        'bpjs_ketenagakerjaan_number': _bpjsTkController.text,
        'ptkp_status': _ptkpController.text,
        'bank_name': _bankNameController.text,
        'bank_account_number': _bankAccountController.text,
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
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BrandPageBackground(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const AppBrandTitle(section: 'Complete Profile'),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      body: _isLoadingOptions
          ? const Center(child: CircularProgressIndicator())
          : _optionsError != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.cloud_off_rounded,
                          size: 48, color: AppColors.primary),
                      SizedBox(height: 12.h),
                      Text(_optionsError!, textAlign: TextAlign.center),
                      SizedBox(height: 16.h),
                      FilledButton(
                          onPressed: () {
                            setState(() => _isLoadingOptions = true);
                            _fetchOptions();
                          },
                          child: const Text('Muat ulang')),
                    ]),
                  ),
                )
              : BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthAuthenticated) {
                      if (state.user.employee != null) {
                        if (state.user.employee!.faceEnrolled) {
                          context.go('/app/home');
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
                              color: AppColors.successEmerald
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                  color: AppColors.successEmerald
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.security,
                                    color: AppColors.successEmerald),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    'Data identitas yang diisi pada tahap ini diproses menggunakan enkripsi di server.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: AppColors.successEmerald),
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
                            decoration: const InputDecoration(
                                labelText: 'Nama Lengkap*'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          SizedBox(height: 16.h),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                                labelText: 'Alamat Email*'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          SizedBox(height: 16.h),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                                labelText: 'Nomor Telepon*'),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (v.length < 9) return 'Nomor tidak valid';
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          TextFormField(
                            controller: _nikController,
                            decoration:
                                const InputDecoration(labelText: 'NIK KTP*'),
                            keyboardType: TextInputType.number,
                            maxLength: 16,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (v.length != 16) return 'NIK harus 16 digit';
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          TextFormField(
                            controller: _npwpController,
                            decoration: const InputDecoration(
                                labelText: 'Nomor NPWP (Opsional)'),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          SizedBox(height: 16.h),
                          TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            onTap: () => _selectDate(_dobController),
                            decoration: const InputDecoration(
                                labelText: 'Tanggal Lahir (YYYY-MM-DD)*'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          SizedBox(height: 16.h),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'Jenis Kelamin'),
                            initialValue: _gender,
                            items: _genders
                                .map((item) => DropdownMenuItem(
                                    value: item['value'],
                                    child: Text(item['label']!)))
                                .toList(),
                            onChanged: (v) => setState(() => _gender = v),
                          ),
                          SizedBox(height: 16.h),
                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Alamat Domisili*',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.my_location),
                                onPressed: _fetchLocationAndAddress,
                                tooltip: 'Get Current Location',
                              ),
                            ),
                            maxLines: 2,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          SizedBox(height: 16.h),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration:
                                const InputDecoration(labelText: 'Departemen'),
                            initialValue: _department,
                            items: _departments
                                .map((dep) => DropdownMenuItem(
                                    value: dep, child: Text(dep)))
                                .toList(),
                            onChanged: (v) => setState(() => _department = v),
                          ),
                          SizedBox(height: 16.h),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'Posisi / Jabatan'),
                            initialValue: _position,
                            items: _positions
                                .map((pos) => DropdownMenuItem(
                                    value: pos, child: Text(pos)))
                                .toList(),
                            onChanged: (v) => setState(() => _position = v),
                          ),
                          SizedBox(height: 16.h),
                          TextFormField(
                            controller: _joinDateController,
                            readOnly: true,
                            onTap: () => _selectDate(_joinDateController),
                            decoration: const InputDecoration(
                                labelText: 'Tanggal Bergabung (YYYY-MM-DD)'),
                          ),
                          SizedBox(height: 16.h),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'Status Kepegawaian*'),
                            initialValue: _employmentStatus,
                            items: _employmentStatuses
                                .map((item) => DropdownMenuItem(
                                    value: item['value'],
                                    child: Text(item['label']!)))
                                .toList(),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Pilih status' : null,
                            onChanged: (v) =>
                                setState(() => _employmentStatus = v),
                          ),
                          SizedBox(height: 24.h),
                          Text('Data Tambahan (Opsional)',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold)),
                          SizedBox(height: 16.h),
                          TextFormField(
                            controller: _bpjsKesController,
                            decoration: const InputDecoration(
                                labelText: 'Nomor BPJS Kesehatan'),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 16.h),
                          TextFormField(
                            controller: _bpjsTkController,
                            decoration: const InputDecoration(
                                labelText: 'Nomor BPJS Ketenagakerjaan'),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 16.h),
                          TextFormField(
                            controller: _ptkpController,
                            decoration: const InputDecoration(
                                labelText: 'Status PTKP (Misal: TK/0, K/1)'),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _bankNameController,
                                  decoration: const InputDecoration(
                                      labelText: 'Nama Bank'),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _bankAccountController,
                                  decoration: const InputDecoration(
                                      labelText: 'Nomor Rekening'),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32.h),
                          SizedBox(
                            width: double.infinity,
                            height: 48.h,
                            child: FilledButton(
                              onPressed:
                                  state is AuthLoading ? null : _submitProfile,
                              child: state is AuthLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text('Lengkapi Profil'),
                            ),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    );
                  },
                ),
    ));
  }
}
