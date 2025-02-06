import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:ml_app/services/model_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController _cameraController;
  late ModelService _modelService;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _modelService = ModelService();
    _modelService.loadModel();
  }

  Future<void>
  _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    _cameraController.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _modelService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weed Detection')),
      body: _isCameraInitialized?
  CameraPreview(_cameraController) : const Center(child: CircularProgressIndicator()),
    );
  }
}
