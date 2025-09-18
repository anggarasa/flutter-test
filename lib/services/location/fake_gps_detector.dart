import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class FakeGPSDetector {
  static const List<String> _knownFakeGpsApps = [
    'com.lexa.fakegps',
    'com.incorporateapps.fakegps.fre',
    'com.blogspot.techzone.fakegps',
    'com.evezzon.fakegps',
    'com.theappninjas.gpsjoystick',
    'com.app.fakelocations',
    'com.fakegps.location',
    'ru.gavrikov.mocklocations',
    'com.mock.location.mockgps',
    'app.greyshirts.snoopsnitch',
    'com.dxshiv.gps.location.mock',
    'com.mock.location',
    'org.hola.fakegps',
  ];

  static Future<FakeGPSDetectionResult> detectFakeGPS() async {
    final detectionReasons = <String>[];
    var isFakeGPSDetected = false;

    try {
      final quickPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.lowest,
          timeLimit: Duration(seconds: 5),
        ),
      );
      if (quickPosition.isMocked == true) {
        isFakeGPSDetected = true;
        detectionReasons.add(
          "Lokasi ditandai sebagai mocked oleh sistem (isMocked = true)",
        );
      }
    } catch (_) {}

    if (await _isDeviceRooted()) {
      detectionReasons.add("Device terdeteksi sudah di-root");
    }

    final detectedFakeApps = await _checkInstalledFakeGpsApps();
    if (detectedFakeApps.isNotEmpty) {
      isFakeGPSDetected = true;
      detectionReasons.add(
        "Aplikasi fake GPS terdeteksi: ${detectedFakeApps.join(', ')}",
      );
    }

    if (Platform.isAndroid && await _isMockLocationEnabled()) {
      isFakeGPSDetected = true;
      detectionReasons.add("Mock Location diaktifkan di pengaturan developer");
    }

    final accuracyCheck = await _checkLocationAccuracy();
    if (accuracyCheck.isSuspicious) {
      isFakeGPSDetected = true;
      detectionReasons.add(accuracyCheck.reason);
    }

    final isSuspiciousPattern = await _checkSuspiciousLocationPattern();
    if (isSuspiciousPattern) {
      isFakeGPSDetected = true;
      detectionReasons.add("Pola lokasi mencurigakan terdeteksi");
    }

    return FakeGPSDetectionResult(
      isFakeGPS: isFakeGPSDetected,
      detectionReasons: detectionReasons,
      confidence: _calculateConfidence(detectionReasons),
    );
  }

  static Future<bool> _isDeviceRooted() async {
    try {
      if (Platform.isAndroid) {
        final rootPaths = <String>[
          '/system/bin/su',
          '/system/xbin/su',
          '/system/sbin/su',
          '/vendor/bin/su',
          '/system/app/Superuser.apk',
          '/data/data/com.noshufou.android.su',
          '/system/app/SuperSU.apk',
        ];
        for (final path in rootPaths) {
          if (await File(path).exists()) return true;
        }
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.isPhysicalDevice == false) return true;
      }
    } catch (_) {}
    return false;
  }

  static Future<List<String>> _checkInstalledFakeGpsApps() async {
    var detectedApps = <String>[];
    try {
      if (Platform.isAndroid) {
        const channel = MethodChannel('com.example.fluttertest/fake_gps');
        final result = await channel.invokeMethod<List<Object?>>(
          'getInstalledFakeGpsApps',
          {'packages': _knownFakeGpsApps},
        );
        detectedApps = (result ?? []).cast<String>();
      }
    } catch (_) {}
    return detectedApps;
  }

  static Future<bool> _isMockLocationEnabled() async {
    try {
      if (Platform.isAndroid) {
        const channel = MethodChannel('com.example.fluttertest/fake_gps');
        final result =
            await channel.invokeMethod<bool>('isMockLocationEnabled') ?? false;
        return result;
      }
    } catch (_) {}
    return false;
  }

  static Future<LocationAccuracyCheck> _checkLocationAccuracy() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (position.accuracy <= 0) {
        return LocationAccuracyCheck(
          isSuspicious: true,
          reason: "Nilai akurasi tidak valid (<= 0m)",
        );
      }
      if (position.latitude.abs() > 90 || position.longitude.abs() > 180) {
        return LocationAccuracyCheck(
          isSuspicious: true,
          reason: "Koordinat di luar rentang valid",
        );
      }
    } catch (_) {}
    return LocationAccuracyCheck(isSuspicious: false, reason: "");
  }

  static Future<bool> _checkSuspiciousLocationPattern() async {
    try {
      final positions = <Position>[];
      for (var i = 0; i < 3; i++) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
        positions.add(position);
      }
      if (positions.length < 2) return false;
      for (var i = 1; i < positions.length; i++) {
        final distance = Geolocator.distanceBetween(
          positions[i - 1].latitude,
          positions[i - 1].longitude,
          positions[i].latitude,
          positions[i].longitude,
        );
        final t1 = positions[i - 1].timestamp;
        final t2 = positions[i].timestamp;
        final timeDiff = t2.difference(t1).inSeconds.toDouble();
        if (timeDiff > 0) {
          final speed = distance / timeDiff;
          final speedKmh = speed * 3.6;
          if (speedKmh > 500) return true;
        }
        if (distance == 0.0 &&
            positions[i].accuracy == positions[i - 1].accuracy &&
            timeDiff >= 2) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  static double _calculateConfidence(List<String> reasons) {
    if (reasons.isEmpty) return 0.0;
    var confidence = 0.0;
    for (final reason in reasons) {
      final r = reason.toLowerCase();
      if (r.contains('ismocked') || r.contains('mocked')) {
        confidence += 0.9;
      } else if (r.contains('aplikasi fake gps')) {
        confidence += 0.8;
      } else if (r.contains('mock location')) {
        confidence += 0.7;
      } else if (r.contains('root')) {
        confidence += 0.3;
      } else if (r.contains('akurasi') ||
          r.contains('altitude') ||
          r.contains('koordinat')) {
        confidence += 0.5;
      } else {
        confidence += 0.4;
      }
    }
    return confidence > 1.0 ? 1.0 : confidence;
  }
}

class FakeGPSDetectionResult {
  final bool isFakeGPS;
  final List<String> detectionReasons;
  final double confidence;

  const FakeGPSDetectionResult({
    required this.isFakeGPS,
    required this.detectionReasons,
    required this.confidence,
  });
}

class LocationAccuracyCheck {
  final bool isSuspicious;
  final String reason;

  const LocationAccuracyCheck({
    required this.isSuspicious,
    required this.reason,
  });
}
