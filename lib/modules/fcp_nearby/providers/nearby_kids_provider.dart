import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'nearby_provider.dart';

//Nearby used by kids
class NearbyKidsProvider extends NearbyProvider{

  List<Device> _parentDevices = [];
  List<Device> get parentDevices => _parentDevices;

  set parentDevices(List<Device> parentDevices){
    _parentDevices = parentDevices;
    notifyListeners();
  }
}