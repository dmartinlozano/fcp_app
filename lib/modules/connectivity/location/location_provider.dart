import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart' as permission_handler;

class LocationProvider with ChangeNotifier{

  Timer? _listener;
  bool _isInitialized = false;
  final Location _location = Location();
  
  permission_handler.PermissionStatus? _permission;
  bool? _state;

  permission_handler.PermissionStatus? get permission => _permission;
  bool? get state => _state;

  set permission(permission_handler.PermissionStatus? permission){
    _permission = permission;
    notifyListeners();
  }

  set state(bool? state){
    _state = state;
    notifyListeners();
  }

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _permission = await permission_handler.PermissionHandlerPlatform.instance.checkPermissionStatus(permission_handler.Permission.location);
    _state = await _location.serviceEnabled();
    notifyListeners();

    _listener = Timer.periodic(const Duration(seconds:  5), (_) async {
      _permission = await permission_handler.PermissionHandlerPlatform.instance.checkPermissionStatus(permission_handler.Permission.location);
      _state = await _location.serviceEnabled();
      notifyListeners();
    });
  }

  Future<bool> isValid() async => _permission != null && _permission == permission_handler.PermissionStatus.granted && 
    _state != null && true == await _location.serviceEnabled();

  //ONLY ANDROID:
  requestPermissions() async {
    await _location.requestPermission();
    notifyListeners();
  }

  enableService() async {
    await _location.requestService();
    notifyListeners();
  }
  
}