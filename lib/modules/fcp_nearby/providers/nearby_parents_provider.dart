import 'dart:async';
import 'package:collection/collection.dart';
import 'package:fcp/modules/play_list/dto/folder_dto.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'nearby_provider.dart';

StreamController _streamController = StreamController.broadcast();

//Nearby used by parents
class NearbyParentsProvider extends NearbyProvider{

  List<NearbyRemoteDevice> _kidsDevices = [];

  List<NearbyRemoteDevice> get kidsDevices => _kidsDevices;
  NearbyRemoteDevice? get kidSelected => _kidsDevices.firstWhereOrNull((NearbyRemoteDevice nearbyRemoteDevice) => nearbyRemoteDevice.isSelected == true);

  NearbyParentsProvider(){
    _streamController.stream.listen((_){
      notifyListeners();
    });
  }

  set kidsDevices(List<NearbyRemoteDevice> kidsDevices){
    _kidsDevices = kidsDevices;
    notifyListeners();
  }
}

class NearbyRemoteDevice{

  String? deviceId;
  String? deviceName;
  SessionState _nearbyState = SessionState.notConnected;
  int? _numBuilder;
  List<FolderDto> _playList = [];
  bool _isPaused = false;
  bool _isLoked = false;
  double _volume = 0.0;
  bool _isSelected = false;
  
  NearbyRemoteDevice.fromDevice(Device device){
    deviceId = device.deviceId;
    deviceName = device.deviceName;
    _nearbyState = device.state;
    _streamController.add(null);
  }

  bool get isSelected => _isSelected;
  SessionState get nearbyState => _nearbyState;
  List<FolderDto> get playList => _playList;
  bool get isPaused => _isPaused;
  bool get isLocked => _isLoked;
  double get volume => _volume;
  int? get numBuilder => _numBuilder;

  set isSelected(bool isSelected){
    _isSelected = isSelected;
    _streamController.add(null);
  }

  set nearbyState(SessionState nearbyState){
    _nearbyState = nearbyState;
    _streamController.add(null);
  }
  
  set playList(List<FolderDto> playList){
    _playList = playList;
    _streamController.add(null);
  }

  set isPaused(bool isPaused){
    _isPaused = isPaused;
    _streamController.add(null);
  }

  set isLocked(bool isLocked){
    _isLoked = isLocked;
    _streamController.add(null);
  }
  
  set volume(double volume){
    _volume = volume;
    _streamController.add(null);
  }

  set numBuilder(int? numBuilder){
    _numBuilder = numBuilder;
    _streamController.add(null);
  }

}

extension ListNearbyRemoteDeviceExtension on List<NearbyRemoteDevice>{
  
  setSelected(int deviceIndex){
    return mapIndexed((i, x) => (i == deviceIndex) ? x.isSelected = true : x.isSelected = false).toList();
  }

  int findByDeviceId(String deviceId){
    return indexWhere((NearbyRemoteDevice d) => d.deviceId == deviceId);
  }
}