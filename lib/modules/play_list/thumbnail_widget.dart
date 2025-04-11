import 'dart:io';

import 'package:fcp/modules/play_list/dto/folder_dto.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/globals.dart';
import '../../utils/i18n.dart';
import '../../widgets/fcp_bottom_sheet_widget.dart';
import 'dto/media_dto.dart';
import 'thumbnail_dto.dart';

class ThumbnailWidget extends StatefulWidget {

  dynamic item; //LocalMediaDto||FolderDto
  bool isSelected;

  ThumbnailWidget({super.key, required this.item, required this.isSelected});

  @override
  State<ThumbnailWidget> createState() => _ThumbnailWidgetState();
}

class _ThumbnailWidgetState extends State<ThumbnailWidget> {

  @override
  Widget build(BuildContext context) {
    if (widget.item is FolderDto){
      return const Icon(Icons.playlist_play, size: 25);
    }else if (widget.item is MediaDto && (widget.item as MediaDto).invalidMediaState != null){
      if ((widget.item as MediaDto).invalidMediaState != null){
        return InkWell(
          onTap:() {
            switch ((widget.item as MediaDto).invalidMediaState){
              case InvalidMediaState.notReproducible:
                FcpBottomSheetWidget bs = FcpBottomSheetWidget(
                  title: Text(I18n.translate('error.media_not_reproducible')),
                  acceptText: (I18n.translate('accept')),
                  acceptOnPress: () => Navigator.of(navigatorKey.currentContext!).pop()
                );
                bs.show();
                break;
              case InvalidMediaState.notExists:
                FcpBottomSheetWidget bs = FcpBottomSheetWidget(
                  title: Text(I18n.translate('error.media_not_found')),
                  acceptText: (I18n.translate('accept')),
                  acceptOnPress: () => Navigator.of(navigatorKey.currentContext!).pop()
                );
                bs.show();
                break;
              case InvalidMediaState.incorrectFile:
              default:
                FcpBottomSheetWidget bs = FcpBottomSheetWidget(
                  title: Text(I18n.translate('error.media_not_compatible')),
                  acceptText: (I18n.translate('accept')),
                  acceptOnPress: () => Navigator.of(navigatorKey.currentContext!).pop()
                );
                bs.show();
            }
          },
          child: const SizedBox(
            width: 100,
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.triangleExclamation,
                size: 25,
                color: Colors.red,
              ),
            ),
          ),
        );
      }
    }else if (widget.item is MediaDto){
      MediaDto mediaDto = widget.item as MediaDto;
      if (mediaDto.thumbnail != null){
        if (mediaDto.thumbnail!.imagePath != null){
          return Container(
            decoration: (widget.isSelected) 
            ? BoxDecoration(
                border: Border.all(
                  color: Colors.redAccent,
                  width: 2.0,
                ),
              ) 
            : null,
            child: Image.file(
              File(mediaDto.thumbnail!.imagePath!),
              width: 100,
              height: 50,
              fit: BoxFit.cover
            )
          );
        }else if (mediaDto.thumbnail!.thumbnailType != null){
          switch (mediaDto.thumbnail!.thumbnailType) {
            case ThumbnailType.musicIcon: return const SizedBox(width: 100, child: Center(child: FaIcon(FontAwesomeIcons.music, size: 25)));
            case ThumbnailType.videoIcon: return  const SizedBox(width: 100, child: Center(child: FaIcon(FontAwesomeIcons.video, size: 25)));
            default: return const SizedBox(width: 100, child: Center(child: FaIcon(FontAwesomeIcons.file, size: 25)));
          }
        }
      }
    }
    return const FaIcon(FontAwesomeIcons.video, size: 25);
  }
}