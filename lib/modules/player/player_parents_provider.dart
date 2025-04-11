import 'package:fcp/modules/play_list/dto/folder_dto.dart';
import 'package:flutter/material.dart';

import '../play_list/dto/media_dto.dart';

class PlayerParentsProvider extends ChangeNotifier {

  FolderDto? _folderSelected;
  MediaDto? _mediaSelected;

  FolderDto? get folderSelected => _folderSelected;
  MediaDto? get mediaSelected => _mediaSelected;

  set folderSelected(FolderDto? folderSelected){
    _folderSelected = folderSelected;
    notifyListeners();
  }

  set mediaSelected(MediaDto? mediaSelected){
    _mediaSelected = mediaSelected;
    notifyListeners();
  }

}