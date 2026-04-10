import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:rider34/core/router/app_router.dart';
import 'package:rider34/core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _mapController = MapController();
  final _destinationCtrl = TextEditingController();

  // Default location — will be replaced with real GPS in next iteration
  final _defaultLocation = const LatLng(-17.8252, 31.0335); // Harare, Zimbabwe

  // Quick-access saved places
  final _quickPlaces = [
    {'icon': Icons.home_outlined, 'label': 'Home'},
    {'icon': Icons.work_outline, 'label': 'Work'},
    {'icon': Icons.history_rounded, 'label': 'Recent'},
  ];

  @override
  void dispose() {
    _destinationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen OpenStreetMap ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultLocation,
              initialZoom: 14.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.loficode.rider34',
              ),
              // Current location pulsing marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: _defaultLocation,
                    width: 60,
                    height: 60,
                    child: _PulsingMarker(),
                  ),
                ],
              ),
              // Simulated nearby driver markers
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      _defaultLocation.latitude + 0.008,
                      _defaultLocation.longitude + 0.012,
                    ),
                    width: 40,
                    height: 40,
                    child: _DriverMarker(),
                  ),
                  Marker(
                    point: LatLng(
                      _defaultLocation.latitude - 0.006,
                      _defaultLocation.longitude - 0.009,
                    ),
                    width: 40,
                    height: 40,
                    child: _DriverMarker(),
                  ),
                ],
              ),
            ],
          ),

          // ── Top bar ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Menu
                  _MapIconButton(
                    icon: Icons.menu_rounded,
                    onTap: () => _openDrawer(context),
                  ),
                  const Spacer(),
                  // "Rider 34" pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Rider 34',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Notifications
                  Stack(
                    children: [
                      _MapIconButton(
                        icon: Icons.notifications_outlined,
                        onTap: () {},
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Sheet ──
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Re-center button
                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _MapIconButton(
                      icon: Icons.my_location_rounded,
                      onTap: () => _mapController.move(_defaultLocation, 14.5),
                    ),
                  ),
                ),

                // Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 30,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle
                        Container(
                          width: 48,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: AppColors.slate200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),

                        // Location inputs
                        _LocationInput(
                          icon: Icons.radio_button_checked,
                          iconColor: AppColors.primary,
                          label: 'Pickup Location',
                          value: 'Current Location',
                          readOnly: true,
                        ),
                        const SizedBox(height: 2),
                        _LocationInput(
                          icon: Icons.location_on_outlined,
                          iconColor: AppColors.slate400,
                          label: 'Where to?',
                          value: '',
                          controller: _destinationCtrl,
                          autofocus: true,
                          trailing: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.slate200,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: AppColors.slate600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Quick-select places
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _quickPlaces.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final place = _quickPlaces[i];
                              return _QuickPlaceChip(
                                icon: place['icon'] as IconData,
                                label: place['label'] as String,
                                onTap: () {},
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Request Ride CTA
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => context.go(AppRoutes.offerFare),
                            icon: const Text(
                              'Request Ride',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            label: const Icon(Icons.arrow_forward, size: 20),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Next: Negotiate your fare',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            color: AppColors.slate400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SideMenu(),
    );
  }
}

// ── Supporting widgets ──────────────────────────────

class _PulsingMarker extends StatefulWidget {
  @override
  State<_PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<_PulsingMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Transform.scale(
            scale: 1.0 + _anim.value * 1.5,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.3 * (1 - _anim.value)),
              ),
            ),
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(color: Color(0x40256AF4), blurRadius: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class _DriverMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.directions_car_rounded,
        color: AppColors.primary,
        size: 18,
      ),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.slate900, size: 22),
      ),
    );
  }
}

class _LocationInput extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final TextEditingController? controller;
  final bool readOnly;
  final bool autofocus;
  final Widget? trailing;

  const _LocationInput({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.controller,
    this.readOnly = false,
    this.autofocus = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextFormField(
                  controller: controller ?? TextEditingController(text: value),
                  readOnly: readOnly,
                  autofocus: autofocus,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.slate900,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.only(bottom: 10),
                    hintText: 'Enter destination',
                    hintStyle: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: AppColors.slate400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class _QuickPlaceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickPlaceChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.slate500),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.slate700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.person_outline, 'My Profile', AppRoutes.profile),
      (Icons.history_rounded, 'Ride History', AppRoutes.rideHistory),
      (Icons.settings_outlined, 'Settings', AppRoutes.settings),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pill
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.slate200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ...items.map(
            (item) => ListTile(
              leading: Icon(item.$1, color: AppColors.slate700),
              title: Text(
                item.$2,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.go(item.$3);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}
