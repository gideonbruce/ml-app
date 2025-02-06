import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
//import 'dart:ui' as ui;
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelService {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/model1.tflite');
  }

  List<Map<String, dynamic>> runInference(Uint8List image) {
    return [{'x': 0.1, 'y': 0.2, 'width': 0.3, 'height': 0.4, 'confidence': 0.9}];

  }

  void dispose() {
    _interpreter.close();
  }
}


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
  List<Map<String, dynamic>> detectionResults = [];

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
      List<Map<String, dynamic>> output = _modelService.runInference(inputImage);

      setState(() {
        detectionResults = output;
      });
    });
  }

  Uint8List _convertCameraImage(CameraImage image) {
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
          CustomPaint(
            painter: BoundingBoxPainter(detectionResults),
          ),
        ],
      )
          : Center(child: Text('Loading model...')),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> detections;
  BoundingBoxPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (var detection in detections) {
      final rect = Rect.fromLTWH(
        detection['x'] * size.width,
        detection['y'] * size.height,
        detection['width'] * size.width,
        detection['height'] * size.height,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
