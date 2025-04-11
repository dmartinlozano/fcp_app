import 'dart:convert';
import 'package:fcp/modules/play_list/dto/media_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../utils/globals.dart';
import '../../../utils/i18n.dart';
import '../../../widgets/dialog_input_widget.dart';
import '../../../widgets/fcp_bottom_sheet_widget.dart';
import '../../player/player_parents_provider.dart';
import '../play_list_provider.dart';
import '../thumbnail_widget.dart';

enum Origin{
  bluetooth,
  stored
}

class FolderDto{

  late String uuid;
  String name;
  List<MediaDto> children = [];

  FolderDto({required this.name, required this.children}){
    uuid = const Uuid().v1();
  }
  
  Map<String, dynamic>? toJson(Origin origin) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['children'] = children.map((MediaDto x) => x.toJson(origin, includeThumbnail: false)).toList();
    return data;
  }

  factory FolderDto.fromJson(Map<String, dynamic> json, Origin origin) {
    return FolderDto(
      name: json["name"], 
      children: (json['children'] as List).map((x) => MediaDto.fromJson(x, origin)).toList()
    );
  }

  Widget toEditExpansionTile(){
    PlayerParentsProvider playerParentsProvider = Provider.of<PlayerParentsProvider>(navigatorKey.currentContext!, listen: false);
    return Slidable(
      key: UniqueKey(),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            label: I18n.translate('rename'),
            backgroundColor: Colors.yellow,
            icon: FontAwesomeIcons.pencil,
            onPressed: (BuildContext contex) => DialogInputWidget(
              acceptText: I18n.translate('accept'),
              cancelText: I18n.translate('cancel'),
              hintText: name,
              acceptOnPress: (String newPlayListName) => playListService.renameFolder(this, newPlayListName),
              cancelOnPress: () => Navigator.of(navigatorKey.currentContext!).pop()
            ).show()
          ),
          SlidableAction(
            label: I18n.translate('delete'),
            backgroundColor: Colors.red,
            icon: Icons.playlist_remove,
            onPressed: (BuildContext contex){
              FcpBottomSheetWidget bs = FcpBottomSheetWidget(
                title: Text(I18n.translate('playlist.confirm_delete')),
                acceptText: I18n.translate('accept'),
                cancelText: I18n.translate('cancel'),
                acceptOnPress: (){
                  playListService.removeByUuid(uuid);
                  Navigator.of(navigatorKey.currentContext!).pop();
                },
                cancelOnPress: () => Navigator.of(navigatorKey.currentContext!).pop(),
              );
              bs.show();
            }
          ),
        ],
      ),
      child: ExpansionTile(
        key: UniqueKey(),
        initiallyExpanded: playerParentsProvider.folderSelected != null && playerParentsProvider.folderSelected!.uuid == uuid,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Icon(Icons.menu)
          ]
        ),
        leading: ThumbnailWidget(item: this, isSelected: false),
        onExpansionChanged: (bool isExpanded){
          if (isExpanded){
            playerParentsProvider.folderSelected = this;
          }else{
            playerParentsProvider.folderSelected = null;
          }
        },
        children: <Widget>[
          children.toEditList(uuid)
        ]
      )
    );
  }

  Widget toViewExpansionTile(){
    PlayerParentsProvider playerParentsProvider = Provider.of<PlayerParentsProvider>(navigatorKey.currentContext!, listen: false);
    return ExpansionTile(
      key: UniqueKey(),
      initiallyExpanded: playerParentsProvider.folderSelected != null && playerParentsProvider.folderSelected!.uuid == uuid,
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      leading: ThumbnailWidget(item: this, isSelected: false),
      onExpansionChanged: (bool isExpanded){
        if (isExpanded){
          playerParentsProvider.folderSelected = this;
        }else{
          playerParentsProvider.folderSelected = null;
        }
      },
      children: <Widget>[
        children.toViewList()
      ]
    );
  }
}

extension ListFolderDtoExtension on List<FolderDto>{

  List<Map<String, dynamic>?> toJson(Origin origin) {
    return map((FolderDto folderDto) => folderDto.toJson(origin)).toList();
  }

  static List<FolderDto> fromJson(String jsonString, Origin origin) {
    List<dynamic> parsedList = jsonDecode(jsonString);
    return parsedList.map((json) => FolderDto.fromJson(json, origin)).toList();
  }

  Widget toReorderableListView(){
    PlayListProvider playListProvider = Provider.of<PlayListProvider>(navigatorKey.currentContext!, listen: false);
    return ReorderableListView(
      key: UniqueKey(),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: map((FolderDto folderDto) => folderDto.toEditExpansionTile()).toList(),
      onReorder: (int oldIndex, int newIndex) {
        if(newIndex > oldIndex) newIndex -= 1;
        FolderDto items = removeAt(oldIndex);
        insert(newIndex, items);
        playListProvider.playList = this;
      }
    );
  }
       
  ListView toListView(){
    return ListView(
      padding: EdgeInsets.zero,
      key: UniqueKey(),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: map((FolderDto folderDto) => folderDto.toViewExpansionTile()).toList(),
    );
  }

  //set MediaDto information in all children
  setInformation() async{
    for (FolderDto folderDto in this){
      for (MediaDto mediaDto in folderDto.children) {
        await playListService.setLocalInformation(mediaDto);
      }
    }
  }

  //find a media and set invalidMediaState field
  updateMediaError(String uuid){
    for (FolderDto folderDto in this){
      for (MediaDto mediaDto in folderDto.children) {
        if (mediaDto.uuid == uuid){
          mediaDto.invalidMediaState = InvalidMediaState.notReproducible;
        }
      }
    }
  }

  //find a media & return next in playlist
  MediaDto? findMediaAndGetNextInPlayList(String uuid){
    for (FolderDto folderDto in this){
      for (int i=0; i<folderDto.children.length; i++){
        int indexMedia = folderDto.children.indexWhere((MediaDto mediaDto) => mediaDto.uuid == uuid);
        if (indexMedia != -1) {
          indexMedia++;
          if (indexMedia >= folderDto.children.length) indexMedia = 0;
          return folderDto.children[indexMedia];
        }
      }
    }
    return null;
  }

  //find a media & return previous in playList
  MediaDto? findMediaAndGetPreviousInPlayList(String uuid){
    for (FolderDto folderDto in this){
      for (int i=0; i<folderDto.children.length; i++){
        int indexMedia = folderDto.children.indexWhere((MediaDto mediaDto) => mediaDto.uuid == uuid);
        if (indexMedia != -1) {
          indexMedia--;
          if (indexMedia < 0) indexMedia = 0;
          return folderDto.children[indexMedia];
        }
      }
    }
    return null;
  }

  //find a media
  MediaDto? findMedia(String uuid){
    for (FolderDto folderDto in this){
      return folderDto.children.firstWhere((MediaDto mediaDto) => mediaDto.uuid == uuid);
    }
    return null;
  }
  
  //update thumbnail
  setThumbnail(MediaDto mediaDtoToFind){
    for (FolderDto folderDto in this){
      for (MediaDto mediaDto in folderDto.children) {
        if (mediaDto.uuid == mediaDtoToFind.uuid){
          mediaDto.thumbnail = mediaDtoToFind.thumbnail;
        }
      }
    }
  }
}