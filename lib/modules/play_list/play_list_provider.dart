import 'dart:convert';
import 'package:fcp/utils/globals.dart';
import 'package:flutter/widgets.dart';
import 'dto/folder_dto.dart';

class PlayListProvider extends ChangeNotifier {
  
  List<FolderDto> _playList = [];
  bool _isProcessing = false;

  List<FolderDto> get playList => _playList;
  bool get isProcessing => _isProcessing;

  set playList(List<FolderDto> playList) {
    _playList = playList;
    preferencesService.playList = jsonEncode(playList.toJson(Origin.stored));
    notifyListeners();
  }

  set isProcessing(bool isProcessing){
    _isProcessing = isProcessing;
    notifyListeners();
  }

  @override
  notifyListeners() {
    preferencesService.playList = jsonEncode(playList.toJson(Origin.stored));
    super.notifyListeners();
  }
}
