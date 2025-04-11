import 'dart:async';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../fcp_nearby/commands/command_type.dart';
import '../play_list/dto/folder_dto.dart';
import '../play_list/dto/media_dto.dart';
import '../play_list/play_list_provider.dart';
import 'player_kids_provider.dart';
import '../../utils/globals.dart';
import '../fcp_nearby/commands/command_data.dart';

//used by kid
class PlayerService{

  final PlayerKidsProvider _playerProvider = Provider.of<PlayerKidsProvider>(navigatorKey.currentContext!, listen: false);
  final PlayListProvider _playListProvider = Provider.of<PlayListProvider>(navigatorKey.currentContext!, listen: false);

  bool isPlaying(){
    if (_playerProvider.playingInfo == null) return false;
    if (_playerProvider.playerController == null) return false;
    if (_playerProvider.playerController!.value.isInitialized) return false;
    return (_playerProvider.playerController!.value.isPlaying);
  }

  play(MediaDto mediaDto) async{
    try{
      _playerProvider.playingInfo = mediaDto;
      _playerProvider.playerController = VideoPlayerController.file(File(mediaDto.path));
      _playerProvider.playerController!.addListener(_localListener);
      await _playerProvider.playerController!.initialize();
      await _playerProvider.playerController!.play();
      if (currentRoute != '/player_page') navigate(routeName: '/player_page');
      fcpNearbyService.sendBroadcastMessage(
        CommandData(
          command: CommandType.playingInfo,
          data: mediaDto.toJson(Origin.bluetooth, includeThumbnail: false)
        )
      );
    }catch(e){
      _playListProvider.playList.updateMediaError(mediaDto.uuid!); //to show in kid's play_list_page (playLocal only is executed in kids)
      mediaDto.invalidMediaState = InvalidMediaState.notReproducible;
      fcpNearbyService.sendBroadcastMessage(
        CommandData(
          command: CommandType.playingError,
          data: mediaDto.uuid
        )
      );
      await next();
    }
  }

  stop() async{
    _playerProvider.playingInfo = null;
    if (_playerProvider.playerController != null){

      removeListener();
      await _playerProvider.playerController!.pause();
      await _playerProvider.playerController!.dispose();
      _playerProvider.playerController = null;
      await Future.delayed(const Duration(seconds: 3));

      orientationService.restore();
      fcpNearbyService.sendBroadcastMessage(
        CommandData(
          command: CommandType.stop,
          data: null
        )
      );
    }
  }

  pause() async{
    if (_playerProvider.playerController != null && _playerProvider.playerController!.value.isInitialized){
      if (_playerProvider.playerController!.value.isPlaying){
        await _playerProvider.playerController!.pause();
      }else{
        await _playerProvider.playerController!.play();
      }
      _playerProvider.isPaused = !_playerProvider.isPaused;
      fcpNearbyService.sendBroadcastMessage(
        CommandData(
          command: CommandType.pause,
          data: _playerProvider.isPaused
        )
      );
    }
  }

  next() async {
    if (_playerProvider.playingInfo != null){
      MediaDto? nextMedia = _playListProvider.playList.findMediaAndGetNextInPlayList(_playerProvider.playingInfo!.uuid!);
      if (nextMedia != null){
        await _playerProvider.playerController!.pause();
        await stop();
        await Future.delayed(const Duration(milliseconds: 200));
        removeListener();
        await play(nextMedia);
      }
    }
  }

  previous() async {
    if (_playerProvider.playingInfo != null){
      MediaDto? nextMedia = _playListProvider.playList.findMediaAndGetPreviousInPlayList(_playerProvider.playingInfo!.uuid!);
      if (nextMedia != null){
        await _playerProvider.playerController!.pause();
        await stop();
        await Future.delayed(const Duration(milliseconds: 200));
        removeListener();
        await play(nextMedia);
      }
    }
  }

   void _localListener() async{
    if (_playerProvider.playerController != null &&
        _playerProvider.playerController is VideoPlayerController &&
        _playerProvider.playerController!.value.isInitialized &&  
        _playerProvider.playerController!.value.position.inMilliseconds == _playerProvider.playerController!.value.duration.inMilliseconds
    ){
      await playerService.next();
    }
  }

  removeListener() async {
    if (_playerProvider.playerController != null){
      _playerProvider.playerController!.removeListener(_localListener);
      await _playerProvider.playerController!.dispose();
    }
  }
}