import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertest/features/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize cameras
  final cameras = await availableCameras();

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fake GPS Camera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(cameras: cameras),
    );
  }
}
