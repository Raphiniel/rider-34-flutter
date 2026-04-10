import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rider34/core/router/app_router.dart';
import 'package:rider34/core/theme/app_theme.dart';
import 'package:rider34/shared/models/ride_model.dart';

class DriverOffersScreen extends StatefulWidget {
  const DriverOffersScreen({super.key});

  @override
  State<DriverOffersScreen> createState() => _DriverOffersScreenState();
}

class _DriverOffersScreenState extends State<DriverOffersScreen> {
  int _refreshSeconds = 15;

  // Mock driver offers data
  final List<DriverOfferModel> _offers = [
    DriverOfferModel(
      id: '1',
      rideId: 'r1',
      driverId: 'd1',
      driverName: 'Michael R.',
      driverRating: 4.9,
      totalRides: 1200,
      offeredPrice: 12.50,
      vehicleMake: 'Honda',
      vehicleModel: 'Civic',
      vehicleColor: 'Grey',
      vehiclePlate: 'ABC 123',
      isVerified: true,
    ),
    DriverOfferModel(
      id: '2',
      rideId: 'r1',
      driverId: 'd2',
      driverName: 'Sarah J.',
      driverRating: 5.0,
      totalRides: 480,
      offeredPrice: 15.00,
      vehicleMake: 'Tesla',
      vehicleModel: 'Model 3',
      vehicleColor: 'White',
      vehiclePlate: 'TES 999',
      isPremium: true,
    ),
    DriverOfferModel(
      id: '3',
      rideId: 'r1',
      driverId: 'd3',
      driverName: 'David K.',
      driverRating: 4.7,
      totalRides: 2500,
      offeredPrice: 13.50,
      vehicleMake: 'Toyota',
      vehicleModel: 'Camry',
      vehicleColor: 'Black',
      vehiclePlate: 'RDE 345',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  void _startRefreshTimer() async {
    for (int i = 15; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _refreshSeconds = i == 0 ? 15 : i);
    }
    _startRefreshTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          color: AppColors.slate500,
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text('Driver Offers'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Sort',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Trip summary
          _TripSummaryCard(passengerOffer: 12.00),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_offers.length} drivers found',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              Text(
                'Refreshing in ${_refreshSeconds}s',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Driver cards
          ...(_offers.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DriverOfferCard(
                offer: entry.value,
                isBestMatch: entry.key == 0,
                onAccept: () => context.go(AppRoutes.activeRide),
              ),
            ),
          )),

          // Loading indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripSummaryCard extends StatelessWidget {
  final double passengerOffer;
  const _TripSummaryCard({required this.passengerOffer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Trip',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                    ),
                  ),
                  const Text(
                    '3.2 mi • 12 min',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      color: AppColors.slate500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Offer: \$${passengerOffer.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RouteRow(
            icon: Icons.circle_outlined,
            color: AppColors.primary,
            address: 'Current Location',
          ),
          const SizedBox(height: 8),
          _RouteRow(
            icon: Icons.circle,
            color: AppColors.primary,
            address: 'My Destination',
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String address;
  const _RouteRow({
    required this.icon,
    required this.color,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 10),
        Text(
          address,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.slate800,
          ),
        ),
      ],
    );
  }
}

class _DriverOfferCard extends StatelessWidget {
  final DriverOfferModel offer;
  final bool isBestMatch;
  final VoidCallback onAccept;

  const _DriverOfferCard({
    required this.offer,
    this.isBestMatch = false,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final isCounterOffer = offer.offeredPrice > 12.00;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBestMatch
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.borderLight,
          width: isBestMatch ? 2 : 1,
        ),
        boxShadow: [
          if (isBestMatch)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          offer.driverName[0],
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    if (offer.isVerified || offer.isPremium)
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: offer.isPremium
                                ? const Color(0xFFFBBF24)
                                : AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            offer.isPremium
                                ? Icons.diamond_rounded
                                : Icons.verified_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + price row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer.driverName,
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate900,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.amber,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${offer.driverRating}',
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.slate700,
                                    ),
                                  ),
                                  Text(
                                    ' (${offer.totalRides >= 1000 ? '${(offer.totalRides / 1000).toStringAsFixed(1)}k' : offer.totalRides} rides)',
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 11,
                                      color: AppColors.slate500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${offer.offeredPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: isBestMatch
                                      ? AppColors.primary
                                      : AppColors.slate900,
                                ),
                              ),
                              if (!isCounterOffer)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Matches Offer',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                )
                              else
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.trending_up_rounded,
                                      color: Colors.orange,
                                      size: 12,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      'Counter Offer',
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Vehicle info
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.directions_car_rounded,
                                  color: AppColors.slate400,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${offer.vehicleMake} ${offer.vehicleModel} • ${offer.vehicleColor}',
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.slate600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.slate200),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                offer.vehiclePlate,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  color: AppColors.slate400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Accept button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isBestMatch
                                ? AppColors.primary
                                : AppColors.slate900,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Accept for \$${offer.offeredPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Badge
          if (isBestMatch)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'BEST MATCH',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          if (offer.isPremium)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'PREMIUM',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
