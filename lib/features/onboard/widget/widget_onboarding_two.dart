import 'package:flutter/material.dart';
import 'package:fluttertest/features/onboard/widget/onboarding_page_content.dart';
import 'package:fluttertest/gen/assets.gen.dart';

class WidgetOnboardingTwo extends StatelessWidget {
  const WidgetOnboardingTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPageContent(
      data: OnboardingData(
        image: Assets.images.imgOnboarding2.svg(fit: BoxFit.contain),
        title: 'Follow Latest\nStyle Shoes',
        subtitle:
            'There Are Many Beautiful And\nAttractive Plants To Your Room',
      ),
    );
  }
}
