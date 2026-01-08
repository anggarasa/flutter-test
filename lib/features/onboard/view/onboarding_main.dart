import 'package:flutter/material.dart';
import 'package:fluttertest/gen/assets.gen.dart';

class OnboardingMain extends StatefulWidget {
  const OnboardingMain({super.key});

  @override
  State<OnboardingMain> createState() => _OnboardingMainState();
}

class _OnboardingMainState extends State<OnboardingMain> {
  int _currentPage = 0;
  final int _totalPages = 3;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
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
                        size: 10,
                      ),
                      _buildDecorativeDot(
                        top: size.height * 0.35,
                        right: size.width * 0.12,
                        size: 12,
                      ),
                      _buildDecorativeDot(
                        top: size.height * 0.42,
                        left: size.width * 0.08,
                        size: 8,
                      ),

                      // Product image (shoe)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: size.height * 0.05),
                          child: Assets.images.imgOnboard1.svg(
                            width: size.width * 0.95,
                            fit: BoxFit.contain,
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
                        const Text(
                          'Start Journey\nWith Nike',
                          style: TextStyle(
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
                          'Smart, Gorgeous & Fashionable\nCollection',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),

                        const Spacer(),

                        // Bottom section with indicators and button
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Page indicators
                              Row(
                                children: List.generate(
                                  _totalPages,
                                  (index) => _buildPageIndicator(
                                    index == _currentPage,
                                  ),
                                ),
                              ),

                              // Get Started button
                              _buildGetStartedButton(),
                            ],
                          ),
                        ),
                      ],
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

  // Decorative dot widget
  Widget _buildDecorativeDot({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFF5B9EE1),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // Page indicator dot
  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF5B9EE1) : const Color(0xFFDCE3E8),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Get Started button
  Widget _buildGetStartedButton() {
    return GestureDetector(
      onTap: () {
        if (_currentPage < _totalPages - 1) {
          setState(() {
            _currentPage++;
          });
        } else {
          // Navigate to next screen
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF5B9EE1),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B9EE1).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
