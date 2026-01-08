import 'package:flutter/material.dart';
import 'package:fluttertest/features/onboard/widget/onboarding_page_content.dart';
import 'package:fluttertest/gen/assets.gen.dart';

class WidgetOnboardingOne extends StatelessWidget {
  const WidgetOnboardingOne({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPageContent(
      data: OnboardingData(
        image: Assets.images.imgOnboard1.svg(fit: BoxFit.contain),
        title: 'Start Journey\nWith Nike',
        subtitle: 'Smart, Gorgeous & Fashionable\nCollection',
      ),
    );
  }
}
