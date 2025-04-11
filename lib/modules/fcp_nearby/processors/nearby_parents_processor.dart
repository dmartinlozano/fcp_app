import 'dart:io';
import 'package:collection/collection.dart';
import 'package:fcp/modules/fcp_nearby/dto/device_info_dto.dart';
import 'package:fcp/modules/fcp_nearby/providers/nearby_parents_provider.dart';
import 'package:fcp/modules/fcp_nearby/processors/nearby_processor.dart';
import 'package:fcp/modules/play_list/dto/folder_dto.dart';
import 'package:fcp/modules/play_list/dto/media_dto.dart';
import 'package:provider/provider.dart';
import '../../../utils/globals.dart';
import '../../player/player_parents_provider.dart';
import '../commands/command_data.dart';
import '../commands/command_type.dart';

class NearbyParentsProcessor implements NearbyProcessor{

  NearbyParentsProvider nearbyParentsProvider = Provider.of<NearbyParentsProvider>(navigatorKey.currentContext!, listen: false);
  PlayerParentsProvider playerParentsProvider = Provider.of<PlayerParentsProvider>(navigatorKey.currentContext!, listen: false);
   
  @override
  processCommand(String deviceId, CommandData command) {
    int indexDeviceFound = nearbyParentsProvider.kidsDevices.findByDeviceId(deviceId);
    if (indexDeviceFound != -1){
      switch (command.command){
      case CommandType.deviceInfo: 
        if (command.data != null){
          DeviceInfoDto dib = DeviceInfoDto.fromJson(command.data);
          nearbyParentsProvider.kidsDevices[indexDeviceFound].numBuilder = dib.numBuilder;
          nearbyParentsProvider.kidsDevices[indexDeviceFound].volume = dib.volume;
          nearbyParentsProvider.kidsDevices[indexDeviceFound].isLocked = dib.isLoked;
          nearbyParentsProvider.kidsDevices[indexDeviceFound].isPaused = dib.isPaused;
          if (Platform.isIOS){
            nearbyParentsProvider.kidsDevices[indexDeviceFound].deviceName = dib.iosDeviceName;
          }
        }
        break;
      case CommandType.playList:
        nearbyParentsProvider.kidsDevices[indexDeviceFound].playList = (command.data as List<dynamic>).map((data) => FolderDto.fromJson(data, Origin.bluetooth)).toList();
        break;
      case CommandType.thumbnail:
        MediaDto mediaDto = MediaDto.fromJson(command.data, Origin.bluetooth);
        nearbyParentsProvider.kidsDevices[indexDeviceFound].playList.setThumbnail(mediaDto);
        break;
      case CommandType.playingInfo:
        if (command.data != null){
          playerParentsProvider.mediaSelected = MediaDto.fromJson(command.data, Origin.bluetooth);
          //select folder parent of mediaSelected
          if (playerParentsProvider.mediaSelected != null){
            for (FolderDto folderDto in nearbyParentsProvider.kidsDevices[indexDeviceFound].playList) { 
              MediaDto? mediaFound = folderDto.children.firstWhereOrNull((MediaDto mediaDto) => mediaDto.uuid == playerParentsProvider.mediaSelected!.uuid);
              if (mediaFound != null) {
                playerParentsProvider.folderSelected = folderDto;
                break;
              }
            }
          }
        }
        break;
      case CommandType.playingError:
        if (command.data != null){
          nearbyParentsProvider.kidsDevices[indexDeviceFound].playList.updateMediaError(command.data);
        }
        break;
      case CommandType.stop:
        playerParentsProvider.folderSelected = null;
        playerParentsProvider.mediaSelected = null;
        nearbyParentsProvider.kidsDevices[indexDeviceFound].isPaused = false;
        break;
      case CommandType.pause:
        nearbyParentsProvider.kidsDevices[indexDeviceFound].isPaused = command.data;
        break;
      case CommandType.volume:
        if (command.data != null){
          nearbyParentsProvider.kidsDevices[indexDeviceFound].volume = command.data;
        }
        break;
      case CommandType.lock:
        nearbyParentsProvider.kidsDevices[indexDeviceFound].isLocked = command.data;
        break;
    }
    }
  }
}