import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:ml_app/app.dart';
import 'screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();
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
      home: HomeScreen(cameras: cameras),
    );
  }
}
