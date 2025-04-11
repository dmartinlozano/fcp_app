import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import '../play_list/dto/media_dto.dart';

//used by kid
class PlayerKidsProvider extends ChangeNotifier {

  VideoPlayerController? _playerController; //must be VideoPlayerController or YoutubePlayerController
  MediaDto? _playingInfo;
  bool _isLoked = false;
  bool _isPaused = false;
  
  bool get isLoked => _isLoked;
  VideoPlayerController? get playerController => _playerController;
  MediaDto? get playingInfo => _playingInfo;
  bool get isPaused => _isPaused;
  
  set isLoked(bool isLoked){
    _isLoked = isLoked;
    notifyListeners();
  }

  set playerController( VideoPlayerController? playerController){
    _playerController = playerController;
    notifyListeners();
  }

  set playingInfo(MediaDto? playingInfo){
    _playingInfo = playingInfo;
    notifyListeners();
  }

  set isPaused(bool isPaused){
    _isPaused = isPaused;
    notifyListeners();
  }

}
