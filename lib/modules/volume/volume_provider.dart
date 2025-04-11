import 'package:flutter/material.dart';

class VolumeProvider extends ChangeNotifier{
  double? _volume;
  double? get volume => _volume;
  set volume(double? volume){
    _volume = volume;
    notifyListeners();
  }
}