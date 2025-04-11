import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:fcp/modules/play_list/dto/folder_dto.dart';
import 'package:fcp/modules/play_list/play_list_provider.dart';
import 'package:ffmpeg_kit_flutter_https_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_https_gpl/media_information.dart';
import 'package:ffmpeg_kit_flutter_https_gpl/media_information_session.dart';
import 'package:ffmpeg_kit_flutter_https_gpl/stream_information.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../utils/globals.dart';
import '../../utils/i18n.dart';
import '../../widgets/fcp_bottom_sheet_widget.dart';
import '../player/player_parents_provider.dart';
import 'dto/media_dto.dart';
import 'thumbnail_dto.dart';

class PlayListService{

  PlayListProvider playListProvider = Provider.of<PlayListProvider>(navigatorKey.currentContext!, listen: false);
  PlayerParentsProvider playerParentsProvider = Provider.of<PlayerParentsProvider>(navigatorKey.currentContext!, listen: false);
  final List<String> _validExtensions = ["mp4", "mkv", "webm", "aac", "mp3", "opus", "flac", "ogg", "mov", "m4v", "m4a", "ac3", "avi"];

  Future<void> init() async {
    playListProvider.playList = ListFolderDtoExtension.fromJson(preferencesService.playList, Origin.stored);
    playListProvider.playList.setInformation();
  }
  
  Future<MediaDto> setLocalInformation(MediaDto mediaDto) async {
    if(File(mediaDto.path).existsSync()){
      MediaInformationSession info = await FFprobeKit.getMediaInformation(mediaDto.path);
      MediaInformation? mp = info.getMediaInformation();
      if (mp != null){
        String durationS = mp.getFormatProperty("duration");
        mediaDto.secDuration = double.parse(durationS);
        mediaDto.codecs = mp.getStreams().map((StreamInformation si) => si.getCodec()).toList();
      }
      if (playListService.isAudio(mediaDto)){
        mediaDto.thumbnail = ThumbnailDto(thumbnailType: ThumbnailType.musicIcon);
      }else if (playListService.isVideo(mediaDto)){
        try{
          Uint8List? fileBytes = await VideoThumbnail.thumbnailData(
            video: mediaDto.path,
            imageFormat: ImageFormat.WEBP,
            timeMs: (mediaDto.secDuration / 2).floor(),
            maxWidth: 100,
            maxHeight: 50,
            quality: 50,
          );
          Directory directory = await getTemporaryDirectory();
          String path = p.join(directory.path, '${mediaDto.uuid}.webp');
          File file = File(path);
          file.createSync();
          file.writeAsBytesSync(fileBytes!.toList());
          mediaDto.thumbnail = ThumbnailDto(
            imageData: fileBytes,
            imagePath: path
          );
        }catch(e){
          //Handle error with only thumbnail
          mediaDto.thumbnail = ThumbnailDto(thumbnailType: ThumbnailType.videoIcon);
        }
      }else{
        mediaDto.invalidMediaState = InvalidMediaState.incorrectFile;
      }
    }else{
      //local file not exists
      mediaDto.invalidMediaState = InvalidMediaState.notExists;
    } 
    return mediaDto;
  }

  addLocalFile() async {
    FilePickerResult? selectedFiles = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: _validExtensions
    );
    if (selectedFiles != null){
      playListProvider.isProcessing = true;
      for (PlatformFile file in selectedFiles.files){
        MediaDto mediaDto = MediaDto(path: file.path!);
        mediaDto = await setLocalInformation(mediaDto);
        if (isAudio(mediaDto) || isVideo(mediaDto)){
          if (playerParentsProvider.folderSelected != null){
            playerParentsProvider.folderSelected!.children.add(mediaDto);
            playListProvider.notifyListeners();
          }else{
            FcpBottomSheetWidget bs = FcpBottomSheetWidget(
              title: Text(I18n.translate('playlist.folder_unselected')),
              acceptText: (I18n.translate('accept')),
              acceptOnPress: () => Navigator.of(navigatorKey.currentContext!).pop()
            );
            bs.show();
          }
        }else{
          mediaDto.invalidMediaState = InvalidMediaState.incorrectFile;
        }
      }
      playListProvider.isProcessing = false;
      playListProvider.notifyListeners();
    }
  }

  addFolder(String newFolder){
    FolderDto folderDto = FolderDto(name: newFolder, children: []);
    playListProvider.playList.add(folderDto);
    playListProvider.notifyListeners();
    playerParentsProvider.folderSelected = folderDto;
  }

  renameFolder(FolderDto folderDto, String newPlayListName){
    folderDto.name = newPlayListName;
    playListProvider.notifyListeners();
  }

  importFolder() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      playListProvider.isProcessing = true;
      Directory dir = Directory(directoryPath);
      List<FileSystemEntity> validFiles = dir.listSync(recursive: false).where((file) {
        if (file is File) {
          String fileExtension = p.extension(file.path).toLowerCase().replaceFirst('.', '');
          return _validExtensions.contains(fileExtension);
        }
        return false;
      }).toList();
      FolderDto folderDto = FolderDto(name: p.basename(directoryPath), children: []);
      playListProvider.playList.add(folderDto);
      playerParentsProvider.folderSelected = folderDto;
      for (FileSystemEntity file in validFiles) {
        MediaDto mediaDto = MediaDto(path: file.path);
        mediaDto = await setLocalInformation(mediaDto);
        if (isAudio(mediaDto) || isVideo(mediaDto)){
          playerParentsProvider.folderSelected!.children.add(mediaDto);
        }else{
          mediaDto.invalidMediaState = InvalidMediaState.incorrectFile;
        }
      }
      playListProvider.isProcessing = false;
      playListProvider.notifyListeners();
    }
  }

  bool isAudio(MediaDto mediaDto){
    final String? mime = lookupMimeType(basename(mediaDto.path));
    return mime?.contains("audio") == true;
  }

  bool isVideo(MediaDto mediaDto){
    final String? mime = lookupMimeType(basename(mediaDto.path));
    return mime?.contains("video") == true;
  }

  removeByUuid(String? uuid) {
    for (FolderDto folderDto in playListProvider.playList){
      if (folderDto.uuid == uuid){
          playListProvider.playList.remove(folderDto);
          playListProvider.notifyListeners();
          if (playerParentsProvider.folderSelected != null && playerParentsProvider.folderSelected?.uuid == uuid){
            playerParentsProvider.folderSelected = null;
          }
        return;
      } else{
        int initialLength = folderDto.children.length;
        folderDto.children.removeWhere((MediaDto mediaDto) => mediaDto.uuid == uuid);
        if (initialLength != folderDto.children.length){
          playListProvider.notifyListeners();
        }
      }
    }
  }

}