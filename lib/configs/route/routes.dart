import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:fluttertest/configs/navigator_key.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: "/splash",
    observers: [ChuckerFlutter.navigatorObserver],
    routerNeglect: true,
    routes: [],
  );
}
