import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late tfl.Interpreter _interpreter;
  bool isModelLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  void _initializeCamera() {
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _loadModel() async {
    _interpreter = await tfl.Interpreter.fromAsset('assets/model.tflite');
    setState(() {
      isModelLoaded = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weed Detection')),
      body: isModelLoaded
          ? _controller.value.isInitialized
          ? CameraPreview(_controller)
          : Center(child: CircularProgressIndicator())
          : Center(child: Text('Loading model...')),
    );
  }
}
