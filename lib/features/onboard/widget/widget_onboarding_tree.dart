import 'package:flutter/material.dart';
import 'package:fluttertest/features/onboard/widget/onboarding_page_content.dart';
import 'package:fluttertest/gen/assets.gen.dart';

class WidgetOnboardingTree extends StatelessWidget {
  const WidgetOnboardingTree({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPageContent(
      data: OnboardingData(
        image: Assets.images.imgOnboarding3.svg(fit: BoxFit.contain),
        title: 'Summer Shoes\nNike 2024',
        subtitle: 'Amet Minim Mlllt Non Deserunt\nUIIamco Est Sit Aliqua Dolor',
      ),
    );
  }
}
