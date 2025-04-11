import 'dart:convert';
import 'package:fcp/modules/fcp_nearby/processors/nearby_processor.dart';
import 'package:fcp/modules/play_list/play_list_provider.dart';
import 'package:provider/provider.dart';
import '../../../utils/globals.dart';
import '../../play_list/dto/media_dto.dart';
import '../../player/player_kids_provider.dart';
import '../commands/command_data.dart';
import '../commands/command_type.dart';

class NearbyKidsProcessor implements NearbyProcessor{

  PlayerKidsProvider playerProvider = Provider.of<PlayerKidsProvider>(navigatorKey.currentContext!, listen: false);
  PlayListProvider playListProvider = Provider.of<PlayListProvider>(navigatorKey.currentContext!, listen: false);
  
  @override
  processCommand(String deviceId, CommandData command) async {
    //deviceId is not used. When a parent send a command, 
    //send to a specific Id and this command its for me
    //or send to broadcast and this command its for me too.
    switch (command.command){
      case CommandType.play:
        MediaDto? mediaDto;
        if (command.data != null && command.data is String){
          mediaDto = MediaDto.fromBluetoothJson(jsonDecode(command.data));
          if (currentRoute != '/player_page') navigate(routeName: '/player_page');
          playerService.play(mediaDto);
        }
        break;
      case CommandType.pause:
        playerService.pause();
        break;
      case CommandType.volume:
        await volumeService.setVolume(command.data);
        break;
      case CommandType.next: 
        await playerService.next();
        break;
      case CommandType.previous: 
        await playerService.previous();
        break;
      case CommandType.lock:
        playerProvider.isLoked = command.data;
        fcpNearbyService.sendBroadcastMessage(
          CommandData(
            command: CommandType.lock,
            data: command.data
          )
        );
        break;
      case CommandType.rotate: 
        orientationService.rotate();
        break;
      case CommandType.stop:
        await playerService.stop();
        orientationService.restore();
        navigate(routeName: "/dashboard_page");
        break;
    } 
  }
}