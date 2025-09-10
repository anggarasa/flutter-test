import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertest/configs/navigator_key.dart';
import 'package:fluttertest/configs/route/routes.dart';
import 'package:fluttertest/configs/theme/app_theme.dart';
import 'package:fluttertest/services/local/shared_preferences/shared_preferences_service.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SharedPrefService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Stack(
            children: [
              ScaffoldMessenger(
                key: scaffoldMessengerKey,
                child: Scaffold(
                  body: MaterialApp.router(
                    title: "AppSos",
                    theme: AppThemes.light(),
                    debugShowCheckedModeBanner: false,
                    builder: (context, child) {
                      final mediaQueryData = MediaQuery.of(context);
                      final scale = mediaQueryData.textScaler.clamp(
                        minScaleFactor: 1.0,
                        maxScaleFactor: 1.0,
                      );
                      return MediaQuery(
                        data: mediaQueryData.copyWith(textScaler: scale),
                        child: child!,
                      );
                    },
                    routerConfig: Routes.router,
                  ),
                ),
              ),
              // if (kDebugMode) ...[
              //   Align(
              //     alignment: Alignment.topRight,
              //     child: SafeArea(
              //       child: SizedBox(
              //         width: 10.w,
              //         child: AppFilledButton(
              //           padding: EdgeInsets.zero,
              //           text: "Show\nChucker",
              //           fontSize: 8,
              //           onPressed: () => ChuckerFlutter.showChuckerScreen(),
              //         ),
              //       ),
              //     ),
              //   ),
              // ],
            ],
          ),
        );
      },
    );
  }
}
