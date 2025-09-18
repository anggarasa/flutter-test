// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../history/domain/photo_location.dart';
import '../../../history/presentation/widgets/success_dialog.dart';
import '../../../history/presentation/widgets/warning_dialog.dart';
import '../../../../services/location/fake_gps_detector.dart';
import '../../../../services/location/location_service.dart';
import '../../../../services/local/photo_local_storage.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  List<CameraDescription> _cameras = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    _cameras = await availableCameras();
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await LocationService.requestPermissions();
    if (_cameras.isNotEmpty) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      _cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing)
      return;
    setState(() => _isProcessing = true);
    try {
      final picture = await _controller!.takePicture();
      await _processPhoto(picture.path);
    } catch (e) {
      _showError('Gagal mengambil foto: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _processPhoto(image.path);
      }
    } catch (e) {
      _showError('Gagal memilih foto: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processPhoto(String photoPath) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
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
      final fakeGPSResult = await FakeGPSDetector.detectFakeGPS();
      if (fakeGPSResult.isFakeGPS) {
        // Navigator.pop(context);
        context.pop();
        showWarningDialog(context, fakeGPSResult);
        try {
          await File(photoPath).delete();
        } catch (_) {}
        return;
      }
      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        // Navigator.pop(context);
        context.pop();
        _showError('Gagal mendapatkan lokasi. Pastikan GPS aktif.');
        return;
      }
      final address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      final photoLocation = PhotoLocation(
        id: uniqueId,
        photoPath: photoPath,
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        timestamp: DateTime.now(),
      );
      await PhotoLocalStorage.savePhotoLocation(photoLocation);
      // Navigator.pop(context);
      context.pop();
      showSuccessDialog(context, photoLocation);
    } catch (e) {
      Navigator.pop(context);
      _showError('Terjadi kesalahan: $e');
    }
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
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text('Memeriksa GPS...'),
                    ],
                  ),
                ),
              );
              final result = await FakeGPSDetector.detectFakeGPS();
              Navigator.pop(context);
              if (result.isFakeGPS) {
                showWarningDialog(context, result);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('GPS terverifikasi asli ✓'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: const Icon(Icons.security),
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
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: _isProcessing ? null : _pickFromGallery,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.photo_library, color: Colors.blue),
                  ),
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
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
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
