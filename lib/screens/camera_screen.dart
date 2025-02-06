import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
    _startDetection();
  }

  Future<void> _loadModel() async {
    await Tflite.loadModel(
      model: "assets/weed_detection.tflite",
      labels: "assets/labels.txt",
    );
  }

  void _startDetection() {
    _controller!.startImageStream((CameraImage image) async {
      if (!_isDetecting) {
        _isDetecting = true;

        var recognitions = await Tflite.runModelOnFrame(
          bytesList: image.planes.map((plane) => plane.bytes).toList(),
          imageHeight: image.height,
          imageWidth: image.width,
          numResults: 2,
          threshold: 0.5,
        );

        if (recognitions!.isNotEmpty) {
          String detectedObject = recognitions.first['label'];
          print("Detected: $detectedObject");

          if (detectedObject.toLowerCase().contains("weed")) {
            _captureAndSaveImage();
          }
        }

        _isDetecting = false;
      }
    });
  }

  Future<void> _captureAndSaveImage() async {
    try {
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/WeedDetection';
      await Directory(dirPath).create(recursive: true);

      final String filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (_controller!.value.isTakingPicture) return;

      XFile imageFile = await _controller!.takePicture();
      File(imageFile.path).copy(filePath);

      print("Image saved: $filePath");
    } catch (e) {
      print("Error saving image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: CameraPreview(_controller!),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    Tflite.close();
    super.dispose();
  }
}
