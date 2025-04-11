import 'package:fcp/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrientationService{

  Orientation? deviceOrientation;

  init() async {
  }

  restore(){
    if (deviceOrientation == Orientation.landscape){
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp
      ]);
    }
    if (deviceOrientation == Orientation.portrait){
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft
      ]);
    }
  }

  rotate(){
    deviceOrientation = MediaQuery.of(navigatorKey.currentContext!).orientation;
    if (deviceOrientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft
      ]);
    } else if (deviceOrientation == Orientation.landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

}