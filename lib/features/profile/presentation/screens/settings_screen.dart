import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rider34/core/router/app_router.dart';
import 'package:rider34/core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _rideAlerts = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go(AppRoutes.profile),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingsSection(
              title: 'Notifications',
              children: [
                _SwitchTile(
                  icon: Icons.notifications_outlined,
                  label: 'Push Notifications',
                  value: _pushNotifications,
                  onChanged: (v) => setState(() => _pushNotifications = v),
                ),
                _SwitchTile(
                  icon: Icons.directions_car_outlined,
                  label: 'Ride Alerts',
                  value: _rideAlerts,
                  onChanged: (v) => setState(() => _rideAlerts = v),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Appearance',
              children: [
                _SwitchTile(
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark Mode',
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Account',
              children: [
                _NavTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Settings',
                  onTap: () {},
                ),
                _NavTile(
                  icon: Icons.language_outlined,
                  label: 'Language',
                  value: 'English',
                  onTap: () {},
                ),
              ],
            ),
            _SettingsSection(
              children: [
                _NavTile(
                  icon: Icons.info_outline_rounded,
                  label: 'App Version',
                  value: '1.0.0',
                  onTap: () {},
                ),
                _NavTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete Account',
                  color: AppColors.error,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _SettingsSection({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              title!.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.slate400,
                letterSpacing: 0.8,
              ),
            ),
          ),
        Container(
          color: Colors.white,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.slate600, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  final Color? color;

  const _NavTile({
    required this.icon,
    required this.label,
    this.value,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.slate600, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.slate900,
        ),
      ),
      trailing: value != null
          ? Text(
              value!,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: AppColors.slate400,
                fontWeight: FontWeight.w500,
              ),
            )
          : const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.slate400,
            ),
      onTap: onTap,
    );
  }
}
