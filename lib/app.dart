import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/camera_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(WeedDetectionApp(cameras: cameras));
}

class WeedDetectionApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const WeedDetectionApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weed Detection App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: CameraScreen(cameras: cameras),
    );
  }
}
