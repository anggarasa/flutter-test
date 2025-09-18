import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Model untuk data foto dan lokasi
class PhotoLocation {
  final String id;
  final String photoPath;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;

  PhotoLocation({
    required this.id,
    required this.photoPath,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photo_path': photoPath,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PhotoLocation.fromMap(Map<String, dynamic> map) {
    return PhotoLocation(
      id: map['id'],
      photoPath: map['photo_path'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      address: map['address'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

// Fake GPS Detection Service
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
    'com.lexa.fakegps',
    'com.dxshiv.gps.location.mock',
    'com.mock.location',
    'org.hola.fakegps',
  ];

  static Future<FakeGPSDetectionResult> detectFakeGPS() async {
    List<String> detectionReasons = [];
    bool isFakeGPSDetected = false;

    // 0. Quick check using Position.isMocked (most reliable on Android)
    try {
      final Position quickPosition = await Geolocator.getCurrentPosition(
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
    } catch (_) {
      // Ignore errors here; we'll continue with other heuristics
    }

    // 1. Check if device is rooted/jailbroken
    if (await _isDeviceRooted()) {
      detectionReasons.add("Device terdeteksi sudah di-root");
    }

    // 2. Check for known fake GPS apps
    List<String> detectedFakeApps = await _checkInstalledFakeGpsApps();
    if (detectedFakeApps.isNotEmpty) {
      isFakeGPSDetected = true;
      detectionReasons.add(
        "Aplikasi fake GPS terdeteksi: ${detectedFakeApps.join(', ')}",
      );
    }

    // 3. Check mock location settings (Android)
    if (Platform.isAndroid && await _isMockLocationEnabled()) {
      isFakeGPSDetected = true;
      detectionReasons.add("Mock Location diaktifkan di pengaturan developer");
    }

    // 4. Check GPS accuracy and provider (relaxed to reduce false positives)
    LocationAccuracyCheck accuracyCheck = await _checkLocationAccuracy();
    if (accuracyCheck.isSuspicious) {
      isFakeGPSDetected = true;
      detectionReasons.add(accuracyCheck.reason);
    }

    // 5. Check for suspicious location patterns
    bool isSuspiciousPattern = await _checkSuspiciousLocationPattern();
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
        // Check common root indicators
        List<String> rootPaths = [
          '/system/bin/su',
          '/system/xbin/su',
          '/system/sbin/su',
          '/vendor/bin/su',
          '/system/app/Superuser.apk',
          '/data/data/com.noshufou.android.su',
          '/system/app/SuperSU.apk',
        ];

        for (String path in rootPaths) {
          if (await File(path).exists()) {
            return true;
          }
        }

        // Check for root management apps
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

        // Basic check for development mode
        if (androidInfo.isPhysicalDevice == false) {
          return true;
        }
      }
    } catch (e) {
      // ignore
    }
    return false;
  }

  static Future<List<String>> _checkInstalledFakeGpsApps() async {
    List<String> detectedApps = [];

    try {
      if (Platform.isAndroid) {
        const MethodChannel channel = MethodChannel(
          'com.example.fluttertest/fake_gps',
        );
        final List<Object?>? result = await channel.invokeMethod<List<Object?>>(
          'getInstalledFakeGpsApps',
          {'packages': _knownFakeGpsApps},
        );
        detectedApps = (result ?? []).cast<String>();
      }
    } catch (e) {
      // ignore
    }

    return detectedApps;
  }

  // Removed unused helper _isAppInstalled; lookups handled in batch via method channel

  static Future<bool> _isMockLocationEnabled() async {
    try {
      if (Platform.isAndroid) {
        const MethodChannel channel = MethodChannel(
          'com.example.fluttertest/fake_gps',
        );
        final bool result =
            await channel.invokeMethod<bool>('isMockLocationEnabled') ?? false;
        return result;
      }
    } catch (e) {
      // ignore
    }
    return false;
  }

  static Future<LocationAccuracyCheck> _checkLocationAccuracy() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // We intentionally avoid flagging based on very high/low accuracy or altitude
      // to minimize false positives. Only flag clearly invalid readings.

      // If accuracy is non-sensical (<= 0) mark suspicious
      if (position.accuracy <= 0) {
        return LocationAccuracyCheck(
          isSuspicious: true,
          reason: "Nilai akurasi tidak valid (<= 0m)",
        );
      }

      // If latitude/longitude are out of bounds, mark suspicious
      if (position.latitude.abs() > 90 || position.longitude.abs() > 180) {
        return LocationAccuracyCheck(
          isSuspicious: true,
          reason: "Koordinat di luar rentang valid",
        );
      }
    } catch (e) {
      // ignore
    }

    return LocationAccuracyCheck(isSuspicious: false, reason: "");
  }

  static Future<bool> _checkSuspiciousLocationPattern() async {
    try {
      List<Position> positions = [];

      // Get multiple location readings
      for (int i = 0; i < 3; i++) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
        positions.add(position);
        await Future.delayed(const Duration(seconds: 2));
      }

      if (positions.length < 2) return false;

      // Check for impossible movement patterns
      for (int i = 1; i < positions.length; i++) {
        double distance = Geolocator.distanceBetween(
          positions[i - 1].latitude,
          positions[i - 1].longitude,
          positions[i].latitude,
          positions[i].longitude,
        );

        final DateTime t1 = positions[i - 1].timestamp;
        final DateTime t2 = positions[i].timestamp;
        double timeDiff = t2.difference(t1).inSeconds.toDouble();

        if (timeDiff > 0) {
          double speed = distance / timeDiff; // meters per second
          double speedKmh = speed * 3.6; // convert to km/h

          // If speed is impossibly high (e.g., >500 km/h for ground movement)
          if (speedKmh > 500) {
            return true;
          }
        }

        // Check for exact coordinates repetition with identical accuracies over time
        if (distance == 0.0 &&
            positions[i].accuracy == positions[i - 1].accuracy &&
            timeDiff >= 2) {
          return true;
        }
      }
    } catch (e) {
      // ignore
    }

    return false;
  }

  static double _calculateConfidence(List<String> reasons) {
    if (reasons.isEmpty) return 0.0;

    double confidence = 0.0;

    for (String reason in reasons) {
      final r = reason.toLowerCase();
      if (r.contains("isMocked".toLowerCase()) || r.contains("mocked")) {
        confidence += 0.9;
      } else if (r.contains("aplikasi fake gps")) {
        confidence += 0.8;
      } else if (r.contains("mock location")) {
        confidence += 0.7;
      } else if (r.contains("root")) {
        confidence += 0.3;
      } else if (r.contains("akurasi") ||
          r.contains("altitude") ||
          r.contains("koordinat")) {
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

  FakeGPSDetectionResult({
    required this.isFakeGPS,
    required this.detectionReasons,
    required this.confidence,
  });
}

class LocationAccuracyCheck {
  final bool isSuspicious;
  final String reason;

  LocationAccuracyCheck({required this.isSuspicious, required this.reason});
}

// Local Storage Helper menggunakan SharedPreferences
class LocalStorageHelper {
  static const String _keyPhotoLocations = 'photo_locations';

  static Future<void> savePhotoLocation(PhotoLocation photoLocation) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing data
    List<PhotoLocation> existingLocations = await getAllPhotoLocations();

    // Add new location
    existingLocations.add(photoLocation);

    // Convert to JSON and save
    List<String> jsonList = existingLocations
        .map((location) => json.encode(location.toMap()))
        .toList();

    await prefs.setStringList(_keyPhotoLocations, jsonList);
  }

  static Future<List<PhotoLocation>> getAllPhotoLocations() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(_keyPhotoLocations);

    if (jsonList == null) return [];

    return jsonList
        .map((jsonString) => PhotoLocation.fromMap(json.decode(jsonString)))
        .toList()
      ..sort(
        (a, b) => b.timestamp.compareTo(a.timestamp),
      ); // Sort by timestamp desc
  }

  static Future<void> deletePhotoLocation(String id) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing data
    List<PhotoLocation> existingLocations = await getAllPhotoLocations();

    // Remove the location with matching id
    existingLocations.removeWhere((location) => location.id == id);

    // Convert to JSON and save
    List<String> jsonList = existingLocations
        .map((location) => json.encode(location.toMap()))
        .toList();

    await prefs.setStringList(_keyPhotoLocations, jsonList);
  }
}

// Service untuk menangani lokasi
class LocationService {
  static Future<bool> requestPermissions() async {
    var status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return position;
    } catch (e) {
      // ignore
      return null;
    }
  }

  static Future<String> getAddressFromCoordinates(
    double lat,
    double lon,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}';
      }
    } catch (e) {
      // ignore
    }
    return 'Lokasi tidak diketahui';
  }
}

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
      title: 'Photo Location Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(cameras: cameras),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MainScreen({super.key, required this.cameras});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [CameraScreen(cameras: widget.cameras), PhotoHistoryScreen()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.location.request();
    await Permission.storage.request();

    if (widget.cameras.isNotEmpty) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile picture = await _controller!.takePicture();
      await _processPhoto(picture.path);
    } catch (e) {
      _showError('Gagal mengambil foto: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _processPhoto(image.path);
      }
    } catch (e) {
      _showError('Gagal memilih foto: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processPhoto(String photoPath) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Memverifikasi lokasi...'),
          ],
        ),
      ),
    );

    try {
      // 1. Detect fake GPS first
      FakeGPSDetectionResult fakeGPSResult =
          await FakeGPSDetector.detectFakeGPS();

      if (fakeGPSResult.isFakeGPS) {
        Navigator.pop(context); // Close loading dialog
        _showFakeGPSWarning(fakeGPSResult);

        // Delete the taken photo if fake GPS is detected
        try {
          await File(photoPath).delete();
        } catch (e) {}

        return;
      }

      // 2. Get current location (only if GPS is genuine)
      Position? position = await LocationService.getCurrentLocation();

      if (position == null) {
        Navigator.pop(context); // Close loading dialog
        _showError('Gagal mendapatkan lokasi. Pastikan GPS aktif.');
        return;
      }

      // 3. Get address from coordinates
      String address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // 4. Generate unique ID
      String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

      // 5. Save to local storage
      PhotoLocation photoLocation = PhotoLocation(
        id: uniqueId,
        photoPath: photoPath,
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        timestamp: DateTime.now(),
      );

      await LocalStorageHelper.savePhotoLocation(photoLocation);

      Navigator.pop(context); // Close loading dialog

      // Show success dialog
      _showSuccessDialog(photoLocation);
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showError('Terjadi kesalahan: $e');
    }
  }

  void _showFakeGPSWarning(FakeGPSDetectionResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('Fake GPS Terdeteksi!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sistem mendeteksi penggunaan fake GPS atau lokasi palsu. Foto tidak dapat disimpan untuk menjaga integritas data lokasi.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Alasan deteksi:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 8),
            ...result.detectionReasons
                .map(
                  (reason) => Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: Colors.red)),
                        Expanded(
                          child: Text(reason, style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red[700], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tingkat kepercayaan deteksi: ${(result.confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(PhotoLocation photoLocation) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text('Foto Berhasil Disimpan!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(photoLocation.photoPath),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.green[700], size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Lokasi terverifikasi asli',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Lokasi: ${photoLocation.address}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Koordinat: ${photoLocation.latitude.toStringAsFixed(6)}, ${photoLocation.longitude.toStringAsFixed(6)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Waktu: ${DateFormat('dd/MM/yyyy HH:mm').format(photoLocation.timestamp)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Location Tracker'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              // Manual fake GPS check
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text('Memeriksa GPS...'),
                    ],
                  ),
                ),
              );

              FakeGPSDetectionResult result =
                  await FakeGPSDetector.detectFakeGPS();
              Navigator.pop(context);

              if (result.isFakeGPS) {
                _showFakeGPSWarning(result);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('GPS terverifikasi asli ✓'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: Icon(Icons.security),
            tooltip: 'Periksa GPS',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isCameraInitialized && _controller != null)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Camera controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery button
                  FloatingActionButton(
                    onPressed: _isProcessing ? null : _pickFromGallery,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.photo_library, color: Colors.blue),
                  ),

                  // Capture button
                  GestureDetector(
                    onTap: _isProcessing ? null : _takePicture,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isProcessing ? Colors.grey : Colors.white,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.blue)
                          : const Icon(
                              Icons.camera_alt,
                              color: Colors.blue,
                              size: 40,
                            ),
                    ),
                  ),

                  // Switch camera button (placeholder)
                  FloatingActionButton(
                    onPressed: () {},
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.flip_camera_ios,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Status indicator
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.security, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Lokasi akan diverifikasi otomatis',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PhotoHistoryScreen extends StatefulWidget {
  const PhotoHistoryScreen({super.key});

  @override
  State<PhotoHistoryScreen> createState() => _PhotoHistoryScreenState();
}

class _PhotoHistoryScreenState extends State<PhotoHistoryScreen> {
  List<PhotoLocation> _photoLocations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotoLocations();
  }

  Future<void> _loadPhotoLocations() async {
    try {
      List<PhotoLocation> locations =
          await LocalStorageHelper.getAllPhotoLocations();
      setState(() {
        _photoLocations = locations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePhoto(PhotoLocation photoLocation) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Hapus Foto'),
        content: const Text('Apakah Anda yakin ingin menghapus foto ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await LocalStorageHelper.deletePhotoLocation(photoLocation.id);
              Navigator.pop(dialogContext);
              _loadPhotoLocations(); // Reload data
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Foto'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photoLocations.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada foto tersimpan',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ambil foto untuk mulai melacak lokasi',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.green[50],
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_user,
                        color: Colors.green[700],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Semua foto telah terverifikasi dengan lokasi asli',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _photoLocations.length,
                    itemBuilder: (context, index) {
                      PhotoLocation photoLocation = _photoLocations[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(photoLocation.photoPath),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            photoLocation.address,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${photoLocation.latitude.toStringAsFixed(6)}, ${photoLocation.longitude.toStringAsFixed(6)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(photoLocation.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Hapus'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deletePhoto(photoLocation);
                              }
                            },
                          ),
                          onTap: () {
                            // Show detailed view
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhotoDetailScreen(
                                  photoLocation: photoLocation,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class PhotoDetailScreen extends StatelessWidget {
  final PhotoLocation photoLocation;

  const PhotoDetailScreen({super.key, required this.photoLocation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Foto'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.file(
                    File(photoLocation.photoPath),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 300,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, size: 50),
                      );
                    },
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Terverifikasi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Verification status
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: Colors.green[700], size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Status Verifikasi Lokasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '✓ Lokasi telah diverifikasi asli',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                  Text(
                    '✓ Tidak terdeteksi penggunaan fake GPS',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                  Text(
                    '✓ Koordinat GPS valid dan akurat',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Location info
            _buildInfoCard('Informasi Lokasi', [
              _buildInfoRow('Alamat', photoLocation.address),
              _buildInfoRow(
                'Latitude',
                photoLocation.latitude.toStringAsFixed(6),
              ),
              _buildInfoRow(
                'Longitude',
                photoLocation.longitude.toStringAsFixed(6),
              ),
              _buildInfoRow(
                'Waktu',
                DateFormat(
                  'EEEE, dd MMMM yyyy HH:mm',
                  'id',
                ).format(photoLocation.timestamp),
              ),
            ]),

            const SizedBox(height: 16),

            // Map button (placeholder)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur peta akan segera hadir!'),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text('Buka di Peta'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
