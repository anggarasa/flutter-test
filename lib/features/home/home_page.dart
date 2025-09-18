import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomePage({super.key, required this.cameras});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isLocationEnabled = false;

  // Fake GPS coordinates
  double _fakeLatitude = -6.2088; // Jakarta default
  double _fakeLongitude = 106.8456;
  String _fakeLocationName = "Jakarta, Indonesia";

  // Real GPS coordinates (for comparison)
  double? _realLatitude;
  double? _realLongitude;
  String _realLocationName = "Unknown";

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  final TextEditingController _locationNameController = TextEditingController();

  List<String> _capturedPhotos = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _requestPermissions();
    _setInitialValues();
  }

  void _setInitialValues() {
    _latController.text = _fakeLatitude.toString();
    _longController.text = _fakeLongitude.toString();
    _locationNameController.text = _fakeLocationName;
  }

  Future<void> _requestPermissions() async {
    // Request camera permission
    await Permission.camera.request();

    // Request location permission
    await Permission.location.request();
    await Permission.locationWhenInUse.request();

    // Get real location for comparison
    _getRealLocation();
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isNotEmpty) {
      _cameraController = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );

      try {
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      } catch (e) {
        print('Error initializing camera: $e');
      }
    }
  }

  Future<void> _getRealLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _realLocationName = "Location services disabled";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _realLocationName = "Location permission denied";
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _realLatitude = position.latitude;
        _realLongitude = position.longitude;
        _realLocationName =
            "Lat: ${position.latitude.toStringAsFixed(4)}, "
            "Lng: ${position.longitude.toStringAsFixed(4)}";
        _isLocationEnabled = true;
      });
    } catch (e) {
      setState(() {
        _realLocationName = "Error getting location: $e";
      });
    }
  }

  void _updateFakeLocation() {
    setState(() {
      _fakeLatitude = double.tryParse(_latController.text) ?? _fakeLatitude;
      _fakeLongitude = double.tryParse(_longController.text) ?? _fakeLongitude;
      _fakeLocationName = _locationNameController.text.isEmpty
          ? "Custom Location"
          : _locationNameController.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fake location updated!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _capturePhoto() async {
    if (!_isCameraInitialized || _cameraController == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Camera not ready!')));
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();

      // Save photo with fake GPS data
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'fake_gps_photo_$timestamp.jpg';
      final String filePath = '${appDir.path}/$fileName';

      await File(photo.path).copy(filePath);

      setState(() {
        _capturedPhotos.insert(0, filePath);
      });

      // Show success message with fake location
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Photo captured with fake location:\n'
            '$_fakeLocationName\n'
            'Lat: ${_fakeLatitude.toStringAsFixed(4)}, '
            'Lng: ${_fakeLongitude.toStringAsFixed(4)}',
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error capturing photo: $e')));
    }
  }

  void _showLocationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GPS Location Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Real Location Info
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Real Location',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(_realLocationName),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Fake Location Settings
            Text(
              'Fake Location Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),

            TextField(
              controller: _locationNameController,
              decoration: InputDecoration(
                labelText: 'Location Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place),
              ),
            ),
            SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.map),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _longController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.map),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Quick Location Buttons
            Text(
              'Quick Locations:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                _quickLocationButton('Jakarta', -6.2088, 106.8456),
                _quickLocationButton('Bali', -8.3405, 115.0920),
                _quickLocationButton('Surabaya', -7.2575, 112.7521),
                _quickLocationButton('Bandung', -6.9175, 107.6191),
              ],
            ),

            Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _updateFakeLocation();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Update Fake Location',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickLocationButton(String name, double lat, double lng) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _latController.text = lat.toString();
          _longController.text = lng.toString();
          _locationNameController.text = name;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black87,
      ),
      child: Text(name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Status Bar
            Container(
              padding: EdgeInsets.all(15),
              color: Colors.black87,
              child: Row(
                children: [
                  Icon(Icons.gps_fixed, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fake GPS: $_fakeLocationName',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: _showLocationSettings,
                    icon: Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Camera Preview
            Expanded(
              flex: 3,
              child: _isCameraInitialized
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: CameraPreview(_cameraController!),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: Center(child: CircularProgressIndicator()),
                    ),
            ),

            // Controls
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.black87,
              child: Column(
                children: [
                  // Location Info
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _fakeLocationName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Lat: ${_fakeLatitude.toStringAsFixed(4)}, '
                                'Lng: ${_fakeLongitude.toStringAsFixed(4)}',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Capture Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery Button
                      IconButton(
                        onPressed: () => _showGallery(),
                        icon: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),

                      // Capture Button
                      GestureDetector(
                        onTap: _capturePhoto,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),

                      // Settings Button
                      IconButton(
                        onPressed: _showLocationSettings,
                        icon: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGallery() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Captured Photos (${_capturedPhotos.length})',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _capturedPhotos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text('No photos captured yet'),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _capturedPhotos.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_capturedPhotos[index]),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _latController.dispose();
    _longController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }
}
