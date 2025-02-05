import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/model_service.dart';
import 'dart:typed_data';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  final ModelService _modelService = ModelService();
  bool isModelLoaded = false;
  String detectionResult = "No detection yet";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  void _initializeCamera() async {
    try {
      _controller = CameraController(widget.cameras.first, ResolutionPreset.medium);
      await _controller.initialize();
      if (!mounted) return;
      setState(() {});
      _startImageStream();
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  Future<void> _loadModel() async {
    await _modelService.loadModel();
    setState(() {
      isModelLoaded = true;
    });
  }

  void _startImageStream() {
    if (!_controller.value.isInitialized) return;

    _controller.startImageStream((CameraImage image) {
      if (!isModelLoaded) return;

      Uint8List inputImage = _convertCameraImage(image);
      List<dynamic> output = _modelService.runInference(inputImage);

      setState(() {
        detectionResult = output.toString();
      });
    });
  }

  Uint8List _convertCameraImage(CameraImage image) {
    // Convert CameraImage to Uint8List (Placeholder, implement actual conversion)
    return Uint8List(image.planes[0].bytes.length)..setAll(0, image.planes[0].bytes);
  }

  @override
  void dispose() {
    _controller.dispose();
    _modelService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weed Detection')),
      body: isModelLoaded
          ? Stack(
        children: [
          _controller.value.isInitialized
              ? CameraPreview(_controller)
              : Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.black54,
              child: Text(
                detectionResult,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      )
          : Center(child: Text('Loading model...')),
    );
  }
}
