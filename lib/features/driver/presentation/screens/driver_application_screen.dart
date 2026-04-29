import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rider34/core/router/app_router.dart';
import 'package:rider34/core/theme/app_theme.dart';
import 'package:rider34/shared/widgets/primary_button.dart';
import 'package:rider34/shared/widgets/app_text_field.dart';

class DriverApplicationScreen extends StatefulWidget {
  const DriverApplicationScreen({super.key});

  @override
  State<DriverApplicationScreen> createState() =>
      _DriverApplicationScreenState();
}

class _DriverApplicationScreenState extends State<DriverApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _policeClearanceCtrl = TextEditingController();
  final _vehicleModelCtrl = TextEditingController();
  final _vehiclePlateCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _licenseCtrl.dispose();
    _policeClearanceCtrl.dispose();
    _vehicleModelCtrl.dispose();
    _vehiclePlateCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'role': 'driver',
            'driver_details': {
              'full_name': _fullNameCtrl.text.trim(),
              'license_number': _licenseCtrl.text.trim(),
              'police_clearance_number': _policeClearanceCtrl.text.trim(),
              'vehicle_model': _vehicleModelCtrl.text.trim(),
              'vehicle_plate': _vehiclePlateCtrl.text.trim(),
            }
          },
        ),
      );

      // Successfully updated, refresh session
      await Supabase.instance.client.auth.refreshSession();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome, Driver! Account updated successfully.'),
          backgroundColor: AppColors.success,
        ),
      );

      context.go(AppRoutes.driverDashboard);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Become a Driver'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go(AppRoutes.profile),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Driver Application',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fill in your details to start driving with Rider 34.',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Personal Details
                  const Text(
                    'Personal Details',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Full Name',
                    placeholder: 'John Doe',
                    leadingIcon: Icons.person_outline_rounded,
                    controller: _fullNameCtrl,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter your full name'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Driver\'s License Number',
                    placeholder: 'DL-12345678',
                    leadingIcon: Icons.badge_outlined,
                    controller: _licenseCtrl,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter your license number'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Police Clearance Ref Number',
                    placeholder: 'Ref-123456',
                    leadingIcon: Icons.verified_user_outlined,
                    controller: _policeClearanceCtrl,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter your clearance number'
                        : null,
                  ),
                  const SizedBox(height: 32),

                  // Vehicle Details
                  const Text(
                    'Vehicle Details',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Vehicle Model',
                    placeholder: 'e.g., Toyota Corolla',
                    leadingIcon: Icons.directions_car_outlined,
                    controller: _vehicleModelCtrl,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter your vehicle model'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Plate Number',
                    placeholder: 'ABC 123',
                    leadingIcon: Icons.pin_outlined,
                    controller: _vehiclePlateCtrl,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter your plate number'
                        : null,
                  ),
                  const SizedBox(height: 40),

                  PrimaryButton(
                    label: 'Submit Application',
                    trailingIcon: Icons.check_circle_outline,
                    onPressed: _submitApplication,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
