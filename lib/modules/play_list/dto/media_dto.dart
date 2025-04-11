import 'dart:convert';
import 'package:fcp/modules/play_list/dto/folder_dto.dart';
import 'package:fcp/modules/play_list/thumbnail_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../utils/globals.dart';
import '../../../utils/i18n.dart';
import '../../fcp_nearby/commands/command_data.dart';
import '../../fcp_nearby/commands/command_type.dart';
import '../../fcp_nearby/providers/nearby_parents_provider.dart';
import '../../player/player_parents_provider.dart';
import '../play_list_provider.dart';
import '../thumbnail_widget.dart';

enum InvalidMediaState{
  incorrectFile,
  notExists,
  notReproducible
}

extension ParsePCToString on InvalidMediaState {
  String value() => toString().split('.').last;
}

class MediaDto{

  String? uuid;
  String path;
  ThumbnailDto? thumbnail;
  double secDuration = 0.0;
  List<String?> codecs = [];
  InvalidMediaState? invalidMediaState;

  MediaDto({required this.path}){
    uuid = const Uuid().v1();
  }

  String getDurationFormatted() {
    Duration duration = Duration(seconds: secDuration.round());
    int hours = duration.inHours;
    int minutes = (duration.inMinutes % 60);
    int remainingSeconds = (duration.inSeconds % 60);
    if (hours == 0) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      String hoursStr = hours.toString().padLeft(2, '0');
      String minutesStr = minutes.toString().padLeft(2, '0');
      String secondsStr = remainingSeconds.toString().padLeft(2, '0');
      return '$hoursStr:$minutesStr:$secondsStr';
    }
  }

  //JSON
  factory MediaDto.fromJson(Map<String, dynamic> x, Origin origin){
    if (origin == Origin.stored) {
      return MediaDto.fromStoredJson(x);
    } else {
      return MediaDto.fromBluetoothJson(x);
    }
  }

  Map<String, dynamic>? toJson(Origin origin, {required bool includeThumbnail}){
    if (origin == Origin.stored){
      return toStoredJson();
    }else{
      return toBluetoothJson(includeThumbnail: includeThumbnail);
    }
  }

  Map<String, dynamic>? toBluetoothJson({required bool includeThumbnail}) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['path'] = path;
    data['secDuration'] = secDuration;
    if (thumbnail != null && includeThumbnail) data["thumbnail"] = thumbnail!.toJson();
    if (invalidMediaState != null) data["invalidMediaState"] = invalidMediaState.toString();
    return data;
  }

  factory MediaDto.fromBluetoothJson(Map<String, dynamic> json) {
    MediaDto mediaDto = MediaDto(path: json["path"]);
    if (json["uuid"] != null) mediaDto.uuid = json["uuid"];
    mediaDto.secDuration = json["secDuration"] != null ? json["secDuration"].toDouble() : 0.0;
    if (json["thumbnail"] != null) mediaDto.thumbnail = ThumbnailDto.fromJson(json["thumbnail"]);
    if (json["invalidMediaState"] != null) mediaDto.invalidMediaState = InvalidMediaState.values.firstWhere((e) => e.toString()==json["invalidMediaState"]);
    return mediaDto;
  }

  Map<String, dynamic>? toStoredJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    return data;
  }

  factory MediaDto.fromStoredJson(Map<String, dynamic> json) {
    MediaDto mediaDto = MediaDto(path: json["path"]);
    mediaDto.uuid = const Uuid().v1();
    return mediaDto;
  }

  Widget toEditTile(){
    return Slidable(
      key: UniqueKey(),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            label: I18n.translate('delete'),
            backgroundColor: Colors.red,
            icon: Icons.delete,
            onPressed: (BuildContext contex) => playListService.removeByUuid(uuid),
          ),
        ],
      ),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child:Text("${basename(path)} - (${getDurationFormatted()})")
            ),
            const Icon(Icons.menu)
          ]
        ),
        leading: ThumbnailWidget(item: this, isSelected: false),
        onTap: (){
          PlayerParentsProvider playerParentsProvider = Provider.of<PlayerParentsProvider>(navigatorKey.currentContext!, listen: false);
          playerParentsProvider.mediaSelected = this;
        } 
      ),
    );
  }
    
  Widget toViewTile(){
    return Consumer<NearbyParentsProvider>(
      builder: (context, nearbyParentsProvider, child) {
        return ListTile(
          leading: ThumbnailWidget(item: this, isSelected: false),
          onTap: (invalidMediaState != null)
          ? null 
          : () {
            if (currentRoute == "/" || currentRoute == "/dashboard_page"){
              playerService.play(this);
            }
            if (nearbyParentsProvider.kidSelected != null){
              fcpNearbyService.sendMessage(
                nearbyParentsProvider.kidSelected!.deviceId!,
                CommandData(
                  command: CommandType.play,
                  data: jsonEncode(toBluetoothJson(includeThumbnail: false))
                )
              );
            }
          },
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text("${basename(path)} - (${getDurationFormatted()})")
              ),
              if (invalidMediaState == null) const Icon(Icons.play_arrow)
            ]
          ),
        );
      }
    );
  }
}

extension ListMediaDtoExtension on List<MediaDto>{

  Widget toEditList(String uuidFolder){
    return ReorderableListView(
      key: UniqueKey(),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: map((MediaDto mediaDto) => mediaDto.toEditTile()).toList(),
      onReorder: (int oldIndex, int newIndex) {
        PlayListProvider playListProvider = Provider.of<PlayListProvider>(navigatorKey.currentContext!, listen: false);
        if (oldIndex < newIndex) newIndex -= 1;
        MediaDto item = removeAt(oldIndex);
        insert(newIndex, item);
        FolderDto folderDto = playListProvider.playList.firstWhere((FolderDto folderDto) => folderDto.uuid == uuidFolder);
        folderDto.children = this;
        playListProvider.notifyListeners();
      },
    );
  }

  Widget toViewList(){
    return ListView(
      key: UniqueKey(),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: map((MediaDto mediaDto) => mediaDto.toViewTile()).toList()
    );
  }


}