import 'package:flutter/material.dart';
import 'configs/route/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Photo Location Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerDelegate: Routes.router.routerDelegate,
      routeInformationParser: Routes.router.routeInformationParser,
      routeInformationProvider: Routes.router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
    );
  }
}
