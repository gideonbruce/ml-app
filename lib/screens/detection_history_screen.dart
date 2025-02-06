import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DetectionHistoryScreen extends StatefulWidget {
  @override
  _DetectionHistoryScreenState createState() => _DetectionHistoryScreenState();
}

class _DetectionHistoryScreenState extends State<DetectionHistoryScreen> {
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/WeedDetection';
    final Directory directory = Directory(dirPath);

    if (directory.existsSync()) {
      setState(() {
        _images = directory.listSync().map((item) => File(item.path)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detection History')),
      body: _images.isEmpty
          ? Center(child: Text("No images detected yet."))
          : GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return Image.file(_images[index]);
        },
      ),
    );
  }
}
