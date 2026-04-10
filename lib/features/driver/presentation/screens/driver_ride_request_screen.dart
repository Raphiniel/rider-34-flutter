import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rider34/core/router/app_router.dart';
import 'package:rider34/core/theme/app_theme.dart';

class DriverRideRequestScreen extends StatelessWidget {
  const DriverRideRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ride Request'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go(AppRoutes.driverDashboard),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Passenger info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alex Smith',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate900,
                          ),
                        ),
                        Row(
                          children: const [
                            Icon(
                              Icons.star_rounded,
                              color: AppColors.amber,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '4.8 rider',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                color: AppColors.slate500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Passenger offer badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          'OFFERING',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate400,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '\$12.00',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slate900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Route
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RouteItem(
                    dot: AppColors.primary,
                    label: 'PICKUP',
                    address: '241 W 34th St',
                  ),
                  Container(
                    height: 32,
                    width: 1,
                    margin: const EdgeInsets.only(left: 6, top: 4, bottom: 4),
                    color: AppColors.slate200,
                  ),
                  _RouteItem(
                    dot: AppColors.slate900,
                    label: 'DROP-OFF',
                    address: 'City Centre Mall',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Trip stats
            Row(
              children: const [
                Expanded(
                  child: _StatTile(
                    icon: Icons.schedule_rounded,
                    label: '~14 min',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    icon: Icons.straighten_rounded,
                    label: '3.2 km',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    icon: Icons.payments_outlined,
                    label: 'Cash',
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go(AppRoutes.driverDashboard),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 56),
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRoutes.activeRide),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Accept Ride',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteItem extends StatelessWidget {
  final Color dot;
  final String label;
  final String address;
  const _RouteItem({
    required this.dot,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.slate400,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              address,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.slate700,
            ),
          ),
        ],
      ),
    );
  }
}
