import 'package:flutter/widgets.dart';

//Nearby used by parents & kids
class NearbyProvider extends ChangeNotifier{

  bool _serviceIsRunning = false;

  bool get serviceIsRunning => _serviceIsRunning;

  set serviceIsRunning(bool serviceIsRunning){
    _serviceIsRunning = serviceIsRunning;
    notifyListeners();
  }

}