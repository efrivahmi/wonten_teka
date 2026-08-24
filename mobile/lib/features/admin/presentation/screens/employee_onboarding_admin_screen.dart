import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class EmployeeOnboardingAdminScreen extends StatefulWidget {
  const EmployeeOnboardingAdminScreen({Key? key}) : super(key: key);
  @override
  State<EmployeeOnboardingAdminScreen> createState() => _EmployeeOnboardingAdminScreenState();
}

class _EmployeeOnboardingAdminScreenState extends State<EmployeeOnboardingAdminScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Onboarding Karyawan', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () { if (_currentStep < 2) setState(() => _currentStep += 1); else context.pop(); },
        onStepCancel: () { if (_currentStep > 0) setState(() => _currentStep -= 1); else context.pop(); },
        steps: [
          Step(title: const Text('Data Pribadi'), content: Column(children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Nama Lengkap')),
            TextFormField(decoration: const InputDecoration(labelText: 'Email')),
            TextFormField(decoration: const InputDecoration(labelText: 'No HP')),
          ]), isActive: _currentStep >= 0, state: _currentStep > 0 ? StepState.complete : StepState.indexed),
          Step(title: const Text('Informasi Pekerjaan'), content: Column(children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Departemen')),
            TextFormField(decoration: const InputDecoration(labelText: 'Jabatan')),
            TextFormField(decoration: const InputDecoration(labelText: 'Tanggal Mulai')),
          ]), isActive: _currentStep >= 1, state: _currentStep > 1 ? StepState.complete : StepState.indexed),
          Step(title: const Text('Dokumen & Kontrak'), content: Column(children: [
            ListTile(leading: const Icon(Icons.upload_file), title: const Text('Upload KTP'), onTap: () {}),
            ListTile(leading: const Icon(Icons.upload_file), title: const Text('Upload Kontrak Kerja'), onTap: () {}),
          ]), isActive: _currentStep >= 2),
        ],
      ),
    );
  }
}
