import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fcp/modules/fcp_nearby/commands/command_data.dart';
import 'package:fcp/modules/fcp_nearby/providers/nearby_kids_provider.dart';
import 'package:fcp/modules/fcp_nearby/providers/nearby_parents_provider.dart';
import 'package:fcp/modules/fcp_nearby/processors/nearby_kids_processor.dart';
import 'package:fcp/modules/fcp_nearby/processors/nearby_processor.dart';
import 'package:fcp/modules/play_list/dto/folder_dto.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../play_list/dto/media_dto.dart';
import '../play_list/play_list_provider.dart';
import '../player/player_kids_provider.dart';
import 'dto/device_info_dto.dart';
import 'commands/command_type.dart';
import 'processors/nearby_parents_processor.dart';
import '../../utils/globals.dart';

class FcpNearbyService{

  NearbyParentsProvider nearbyParentsProvider = Provider.of<NearbyParentsProvider>(navigatorKey.currentContext!, listen: false);
  NearbyKidsProvider nearbyKidsProvider = Provider.of<NearbyKidsProvider>(navigatorKey.currentContext!, listen: false);
  PlayerKidsProvider playerProvider = Provider.of<PlayerKidsProvider>(navigatorKey.currentContext!, listen: false);
  PlayListProvider playListProvider = Provider.of<PlayListProvider>(navigatorKey.currentContext!, listen: false);
  final NearbyService _nearbyService = NearbyService();
  StreamSubscription? _stateChangedSubscription;
  StreamSubscription? _receivedDataSubscription;

  bool isParentMode = false;

  init({required bool isParentMode}) async {

    this.isParentMode = isParentMode;

    String? deviceName;
    if (deviceInfo != null && deviceInfo is AndroidDeviceInfo){
      if (preferencesService.customName == null){
        deviceName = "${(deviceInfo as AndroidDeviceInfo).manufacturer} - ${(deviceInfo as AndroidDeviceInfo).model}";
      }else{
        deviceName = preferencesService.customName!;
      }
    }
    if (deviceInfo != null && deviceInfo is IosDeviceInfo){
      deviceName = (deviceInfo as IosDeviceInfo).identifierForVendor ?? const Uuid().v1();
    }

    await _nearbyService.init(
      serviceType: 'mpconn',
      deviceName: deviceName,
      strategy: Strategy.P2P_CLUSTER,
      callback: (isRunning) async {
        if (isRunning) {
          if (isParentMode){
            nearbyParentsProvider.serviceIsRunning = true;
            await _nearbyService.stopBrowsingForPeers();
            await Future.delayed(const Duration(microseconds: 200));
            await _nearbyService.startBrowsingForPeers();
          }else{
            nearbyKidsProvider.serviceIsRunning = true;
            await _nearbyService.stopAdvertisingPeer();
            await _nearbyService.stopBrowsingForPeers();
            await Future.delayed(const Duration(microseconds: 200));
            await _nearbyService.startAdvertisingPeer();
            await _nearbyService.startBrowsingForPeers();
          }
        }else{
          if (isParentMode){
            nearbyParentsProvider.serviceIsRunning = false;
          }else{
            nearbyKidsProvider.serviceIsRunning = false;
          }
        }
    });
    _stateChangedSubscription = _nearbyService.stateChangedSubscription(callback: (List<Device> devices) async {
      nearbyParentsProvider.kidsDevices = devices.map((Device d) => NearbyRemoteDevice.fromDevice(d)).toList();
      nearbyKidsProvider.parentDevices = devices;
      if (!isParentMode) await kidSendState();
      analyticsService.nearbyLog(isParentMode);
    });

    _receivedDataSubscription = _nearbyService.dataReceivedSubscription(callback: (dataRaw) async {
      CommandData commandData = CommandData.fromJson(dataRaw);
      NearbyProcessor processor = (isParentMode) ? NearbyParentsProcessor() : NearbyKidsProcessor();
      String deviceId = dataRaw["senderDeviceId"] ?? dataRaw["deviceId"];
      processor.processCommand(deviceId, commandData);
    });
  }

  Future<void> invitePeer(NearbyRemoteDevice device) async {
    _nearbyService.invitePeer(
      deviceID: device.deviceId!,
      deviceName: device.deviceName,
    );
  }

  void disconnectPeer(String deviceId){
    _nearbyService.disconnectPeer(deviceID: deviceId);
  }

   //used by kids
  sendBroadcastMessage(CommandData data) {
    for(Device device in nearbyKidsProvider.parentDevices){
      if (device.state == SessionState.connected){
        sendMessage(device.deviceId, data);
      }
    }
  }

  sendMessage(String deviceId, CommandData data) async {
    _nearbyService.sendMessage(deviceId, jsonEncode(data.toJson()));
  }

  stop() async{
    for(NearbyRemoteDevice device in nearbyParentsProvider.kidsDevices){
      if (device.nearbyState == SessionState.connected) disconnectPeer(device.deviceId!);
    }
    for(Device device in nearbyKidsProvider.parentDevices){
      if (device.state == SessionState.connected) disconnectPeer(device.deviceId);
    }
    nearbyParentsProvider.kidsDevices = [];
    nearbyKidsProvider.parentDevices = [];
    if (nearbyParentsProvider.serviceIsRunning) await _nearbyService.stopBrowsingForPeers();
    if (nearbyKidsProvider.serviceIsRunning){
      await _nearbyService.stopAdvertisingPeer();
      await _nearbyService.stopBrowsingForPeers();
    }
    if (_stateChangedSubscription != null) await _stateChangedSubscription?.cancel();
    if (_receivedDataSubscription != null) await _receivedDataSubscription?.cancel();
  }

  kidSendState() async {

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    double volume = await volumeService.getVolume();

    DeviceInfoDto deviceInfoDto = DeviceInfoDto(
      numBuilder: int.parse(packageInfo.buildNumber),
      isLoked: playerProvider.isLoked,
      isPaused: playerProvider.isPaused,
      volume: volume,
    );

    if (Platform.isIOS){
      if (preferencesService.customName == null){
        deviceInfoDto.iosDeviceName = (deviceInfo as IosDeviceInfo).name;
      } else{
        deviceInfoDto.iosDeviceName = preferencesService.customName;
      }
    }

    //send deviceInfo
    sendBroadcastMessage(
      CommandData(
        command: CommandType.deviceInfo,
        data: deviceInfoDto.toJson()
      )
    );
    //send localPlayList
    sendBroadcastMessage(
      CommandData(
        command: CommandType.playList,
        data: playListProvider.playList.toJson(Origin.bluetooth)
      )
    );
    
    //send thumbnail for localPlayList
    for (FolderDto folderDto in playListProvider.playList){
      for (MediaDto mediaDto in folderDto.children) {
        sendBroadcastMessage(
          CommandData(
            command: CommandType.thumbnail,
            data: mediaDto.toJson(Origin.bluetooth, includeThumbnail: true)
          )
        );
      }
    }

    //send playingInfo
    sendBroadcastMessage(
      CommandData(
        command: CommandType.playingInfo,
        data: (playerProvider.playingInfo == null) ? null : playerProvider.playingInfo!.toJson(Origin.bluetooth, includeThumbnail: false)
      )
    );
  }
}