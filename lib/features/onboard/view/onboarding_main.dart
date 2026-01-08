import 'package:flutter/material.dart';
import 'package:fluttertest/features/onboard/widget/widget_onboarding_one.dart';
import 'package:fluttertest/features/onboard/widget/widget_onboarding_two.dart';
import 'package:fluttertest/features/onboard/widget/widget_onboarding_tree.dart';

class OnboardingMain extends StatefulWidget {
  const OnboardingMain({super.key});

  @override
  State<OnboardingMain> createState() => _OnboardingMainState();
}

class _OnboardingMainState extends State<OnboardingMain> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to next screen (e.g., login or home)
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    }
  }

  void _skipOnboarding() {
    // Navigate to next screen directly
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // PageView for onboarding pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: const [
                  WidgetOnboardingOne(),
                  WidgetOnboardingTwo(),
                  WidgetOnboardingTree(),
                ],
              ),
            ),

            // Bottom section with indicators and button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicators
                  Row(
                    children: List.generate(
                      _totalPages,
                      (index) => _buildPageIndicator(index == _currentPage),
                    ),
                  ),

                  // Get Started / Next button
                  _buildActionButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Page indicator dot
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

  /// Action button (Next / Get Started)
  Widget _buildActionButton() {
    final isLastPage = _currentPage == _totalPages - 1;

    return GestureDetector(
      onTap: _nextPage,
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
        child: Text(
          isLastPage ? 'Get Started' : 'Next',
          style: const TextStyle(
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
