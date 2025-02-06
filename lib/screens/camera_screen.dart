import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite/tflite.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isDetecting = false;
  String _result = "Detecting...";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    await _controller.initialize();
    if (!mounted) return;
    setState(() {});

    _controller.startImageStream((CameraImage image) {
      if (!_isDetecting) {
        _isDetecting = true;
        _runModel(image).then((_) => _isDetecting = false);
      }
    });
  }

  Future<void> _loadModel() async {
    await Tflite.loadModel(
      model: "assets/weed_detection.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> _runModel(CameraImage image) async {
    var recognitions = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((plane) => plane.bytes).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      numResults: 3,
      threshold: 0.5,
    );

    if (recognitions.isNotEmpty) {
      setState(() {
        _result = recognitions.map((e) => e['label']).join(", ");
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_controller), // Full-screen camera preview
        Positioned(
          bottom: 50,
          left: 20,
          right: 20,
          child: Container(
            padding: EdgeInsets.all(12),
            color: Colors.black54,
            child: Text(
              _result,
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
