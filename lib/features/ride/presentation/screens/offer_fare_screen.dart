import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rider34/core/router/app_router.dart';
import 'package:rider34/core/theme/app_theme.dart';

class OfferFareScreen extends StatefulWidget {
  const OfferFareScreen({super.key});

  @override
  State<OfferFareScreen> createState() => _OfferFareScreenState();
}

class _OfferFareScreenState extends State<OfferFareScreen> {
  double _offerPrice = 25.0;
  final _suggestedPrices = [22.0, 25.0, 28.0];

  void _adjustPrice(double delta) {
    setState(() {
      _offerPrice = (_offerPrice + delta).clamp(5.0, 200.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Negotiate Fare'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Map preview
          Container(
            height: MediaQuery.of(context).size.height * 0.28,
            color: AppColors.backgroundLight,
            child: Stack(
              children: [
                // Map placeholder (replace with FlutterMap + route polyline)
                Container(
                  color: const Color(0xFFE8F0FD),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_rounded,
                          size: 48,
                          color: AppColors.primary.withOpacity(0.4),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Route Preview',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            color: AppColors.slate400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Trip stats
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Row(
                    children: [
                      _TripStatChip(
                        icon: Icons.schedule_rounded,
                        label: '24 min',
                      ),
                      const SizedBox(width: 8),
                      _TripStatChip(
                        icon: Icons.straighten_rounded,
                        label: '8.2 km',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 4),

                  // Route card
                  Transform.translate(
                    offset: const Offset(0, -16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: const [
                          _RouteStop(
                            dot: AppColors.primary,
                            isSquare: false,
                            label: 'Pickup',
                            address: '241 W 34th St',
                            sub: 'Current Location',
                          ),
                          SizedBox(height: 12),
                          _RouteStop(
                            dot: AppColors.slate900,
                            isSquare: true,
                            label: 'Drop-off',
                            address: 'My Destination',
                            sub: 'Tap to edit',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Offer section
                  const Text(
                    'Your Offer',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Fair price: \$22 – \$28',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Price control
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Minus
                      GestureDetector(
                        onTap: () => _adjustPrice(-1),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: const Icon(
                            Icons.remove_rounded,
                            color: AppColors.slate600,
                          ),
                        ),
                      ),

                      // Price display
                      Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Text(
                                '\$${_offerPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 44,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.slate900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Plus
                      GestureDetector(
                        onTap: () => _adjustPrice(1),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quick select chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _suggestedPrices.map((price) {
                      final selected = _offerPrice == price;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          onTap: () => setState(() => _offerPrice = price),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryLight
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.borderLight,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              '\$$price',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.slate600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Fixed bottom bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: AppColors.slate500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: const [
                    Icon(
                      Icons.payments_outlined,
                      color: AppColors.slate700,
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Cash',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.driverOffers),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Find Driver',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.circle, size: 4),
                    const SizedBox(width: 8),
                    Text(
                      '\$${_offerPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TripStatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteStop extends StatelessWidget {
  final Color dot;
  final bool isSquare;
  final String label;
  final String address;
  final String sub;

  const _RouteStop({
    required this.dot,
    required this.isSquare,
    required this.label,
    required this.address,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 4, right: 12),
              decoration: BoxDecoration(
                color: dot,
                borderRadius: BorderRadius.circular(isSquare ? 2 : 6),
              ),
            ),
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate400,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              Text(
                sub,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  color: AppColors.slate500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
