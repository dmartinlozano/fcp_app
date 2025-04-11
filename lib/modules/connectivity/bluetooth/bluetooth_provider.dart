import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

class BluetoothProvider with ChangeNotifier{

  Timer? _listener;
  bool _isInitialized = false;

  PermissionStatus? _permission;
  BluetoothAdapterState? _state;

  PermissionStatus? get permission => _permission;
  BluetoothAdapterState? get state => _state;

  set permission(PermissionStatus? permission){
    _permission = permission;
    notifyListeners();
  }

  set state(BluetoothAdapterState? state){
    _state = state;
    notifyListeners();
  }

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _permission = await PermissionHandlerPlatform.instance.checkPermissionStatus(Permission.bluetooth);
    _state = await FlutterBluePlus.adapterState.first;
    notifyListeners();

    _listener = Timer.periodic(const Duration(seconds:  5), (_) async {
      _permission = await PermissionHandlerPlatform.instance.checkPermissionStatus(Permission.bluetooth);
      _state = await FlutterBluePlus.adapterState.first;
      notifyListeners();
    });
  }

  bool isValid() => _permission != null && _permission == PermissionStatus.granted && 
    _state != null && _state == BluetoothAdapterState.on;

  //ONLY ANDROID:
  requestPermissions() async {
    Map<Permission, PermissionStatus> permissionStatus = await PermissionHandlerPlatform.instance.requestPermissions([Permission.bluetooth]);
    _permission = permissionStatus[Permission.bluetooth];
    notifyListeners();
  }

  enableService() async {
    await FlutterBluePlus.turnOn();
    notifyListeners();
  }
}