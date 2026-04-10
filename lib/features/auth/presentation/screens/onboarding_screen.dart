import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rider34/core/router/app_router.dart';
import 'package:rider34/core/theme/app_theme.dart';
import 'package:rider34/shared/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.local_taxi_rounded,
      title: 'You Name the Price',
      description:
          'Set your own fare and let drivers compete for your ride. No surge pricing, no surprises.',
    ),
    _OnboardingPage(
      icon: Icons.handshake_rounded,
      title: 'Negotiate Freely',
      description:
          'Drivers send counter-offers in real time. Accept the deal that works for you.',
    ),
    _OnboardingPage(
      icon: Icons.verified_user_rounded,
      title: 'Safe & Insured',
      description:
          'Every Rider 34 trip is insured. Share your trip with family and stay protected.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    color: AppColors.slate400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: _pages,
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppColors.primary
                        : AppColors.slate200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _currentPage == _pages.length - 1
                  ? Column(
                      children: [
                        PrimaryButton(
                          label: 'Get Started',
                          trailingIcon: Icons.arrow_forward,
                          onPressed: () => context.go(AppRoutes.signup),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already a member? ',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                color: AppColors.slate500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go(AppRoutes.login),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : PrimaryButton(
                      label: 'Next',
                      trailingIcon: Icons.arrow_forward,
                      onPressed: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      ),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(icon, color: AppColors.primary, size: 64),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.slate900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.slate500,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
