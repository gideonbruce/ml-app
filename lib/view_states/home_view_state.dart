
import 'package:realtime_weed_detection/services/tensorflow_service.dart';

import 'package:realtime_weed_detection/models/recognition.dart';

class HomeViewState {

  ModelType type;

  late List<Recognition> recognitions = <Recognition>[];

  int widthImage = 0;

  int heightImage = 0;


  int cameraIndex = 0;

  HomeViewState(this.type);

  bool isFrontCamera() {
    return cameraIndex == 1;
  }

  bool isBackCamera() {
    return cameraIndex == 0;
  }

  bool isYolo() {
    return type == ModelType.YOLO;
  }

  bool isSSDMobileNet() {
    return type == ModelType.SSDMobileNet;
  }

  bool isMobileNet() {
    return type == ModelType.MobileNet;
  }

  bool isPoseNet() {
    return type == ModelType.PoseNet;
  }

}