import 'package:flutter/material.dart';
import 'package:fluttertest/gen/assets.gen.dart';

/// Model data untuk konten onboarding
class OnboardingData {
  final Widget image;
  final String title;
  final String subtitle;

  const OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

/// Widget reusable untuk konten halaman onboarding
class OnboardingPageContent extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPageContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Background ring gradient - positioned at top right
        Positioned(
          top: -50,
          right: -100,
          child: SizedBox(
            width: size.width * 0.9,
            height: size.width * 0.9,
            child: Assets.images.imgOnbardingRing.svg(fit: BoxFit.contain),
          ),
        ),

        // Main content
        Column(
          children: [
            // Image section with decorative dots
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  // Decorative dots
                  _buildDecorativeDot(
                    top: size.height * 0.12,
                    left: size.width * 0.15,
                    dotSize: 10,
                  ),
                  _buildDecorativeDot(
                    top: size.height * 0.35,
                    right: size.width * 0.12,
                    dotSize: 12,
                  ),
                  _buildDecorativeDot(
                    top: size.height * 0.42,
                    left: size.width * 0.08,
                    dotSize: 8,
                  ),

                  // Product image
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: size.height * 0.05),
                      child: SizedBox(
                        width: size.width * 0.95,
                        child: data.image,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Text content section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B2B2B),
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtitle
                    Text(
                      data.subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Decorative dot widget
  Widget _buildDecorativeDot({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double dotSize,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: dotSize,
        height: dotSize,
        decoration: const BoxDecoration(
          color: Color(0xFF5B9EE1),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
