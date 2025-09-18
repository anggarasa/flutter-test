import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:fluttertest/configs/navigator_key.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/main/presentation/pages/main_page.dart';
import '../../features/history/presentation/pages/photo_detail_page.dart';
import '../../features/history/domain/photo_location.dart';
import 'route_name.dart';

class Routes {
  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: "/",
    observers: [ChuckerFlutter.navigatorObserver],
    routerNeglect: true,
    routes: [
      GoRoute(
        name: RouteName.main,
        path: '/',
        builder: (context, state) => const MainPage(),
        routes: [
          GoRoute(
            name: 'photo_detail',
            path: 'photo-detail',
            builder: (context, state) {
              final photo = state.extra as PhotoLocation?;
              if (photo == null) return const SizedBox.shrink();
              return PhotoDetailPage(photoLocation: photo);
            },
          ),
        ],
      ),
    ],
  );
}
