import 'package:fcp/modules/play_list/dto/folder_dto.dart';
import 'package:flutter/material.dart';

enum PlayListMode{
  view,
  edit,
}

class PlayListWidget extends StatelessWidget {

  final List<FolderDto> list;
  final PlayListMode mode;

  const PlayListWidget({super.key, required this.list, required this.mode});

  @override
  Widget build(BuildContext context) {
    return (mode == PlayListMode.edit)
              ? list.toReorderableListView()
              : list.toListView();
         
  }
}