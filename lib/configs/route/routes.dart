import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:fluttertest/configs/navigator_key.dart';
import 'package:fluttertest/features/onboard/view/onboarding_main.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: "/onboarding",
    observers: [ChuckerFlutter.navigatorObserver],
    routerNeglect: true,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingMain(),
      ),
    ],
  );
}
