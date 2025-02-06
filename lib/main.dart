import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/camera_screen.dart';

late List<CameraDescription> cameras; // Declare cameras globally

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // Get camera list before running app
  runApp(const WeedDetectionApp());
}

class WeedDetectionApp extends StatelessWidget {
  const WeedDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weed Detection App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: CameraScreen(cameras: cameras), // Pass cameras properly
    );
  }
}
