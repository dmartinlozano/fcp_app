import 'package:fcp/modules/dark_mode/dark_mode_provider.dart';
import 'package:fcp/modules/player/player_parents_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marquee/marquee.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../../utils/globals.dart';
import '../../utils/i18n.dart';
import '../fcp_nearby/commands/command_data.dart';
import '../fcp_nearby/commands/command_type.dart';
import '../fcp_nearby/providers/nearby_parents_provider.dart';
import 'dto/media_dto.dart';

class PlayListControllerWidget extends SliverPersistentHeaderDelegate {

  final double expandedHeight;

  PlayListControllerWidget({
    required this.expandedHeight
  });

  double _parseVolumeToSlider(NearbyParentsProvider nearbyParentsProvider){
    if (nearbyParentsProvider.kidSelected == null){
      return 0.0;
    }else if (nearbyParentsProvider.kidSelected!.volume <= 1){
      return nearbyParentsProvider.kidSelected!.volume * 100;
    }else{
      return nearbyParentsProvider.kidSelected!.volume;
    }
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final appBarSize = expandedHeight - shrinkOffset;
    final cardTopPosition = expandedHeight / 2 - shrinkOffset;
    final proportion = 2 - (expandedHeight / appBarSize);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;
    final double notchHeight = MediaQuery.of(context).padding.top;
    return Consumer3<NearbyParentsProvider, PlayerParentsProvider, DarkModeProvider>(
      builder: (_, nearbyParentsProvider, playerParentsProvider, darkModeProvider, __) {
        return SizedBox(
          height: expandedHeight + expandedHeight / 2,
          child: Stack(
            children: [
              SizedBox(
                height: appBarSize < kToolbarHeight ? kToolbarHeight : appBarSize,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/music.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              //Marquee title
              Positioned(
                left: 100,
                right: 100,
                top: notchHeight + 5,
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 20,
                    width: 500,
                    child: Marquee(
                      text: (playerParentsProvider.mediaSelected == null)
                          ? I18n.translate('player.playing_none') 
                          : basename((playerParentsProvider.mediaSelected as MediaDto).path),
                      style: const TextStyle(color: Colors.white),
                      blankSpace: 50.0,
                    ),
                  )
                )
              ),
              (playerParentsProvider.mediaSelected == null)
              ? Container()
              : Positioned(
                  left: 0.0,
                  right: 0.0,
                  top: cardTopPosition > 0 ? cardTopPosition : 0,
                  bottom: 0.0,
                  child: Opacity(
                    opacity: percent,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30 * percent),
                      child: Container(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        decoration: BoxDecoration(
                          color: (darkModeProvider.enabledDarkMode) ? Colors.black : Colors.white, 
                          borderRadius: const BorderRadius.all(Radius.circular(25)), 
                          boxShadow: [BoxShadow(color: Colors.grey.shade500, blurRadius: 10.0, spreadRadius: 0.1)]
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                              //1st row:
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(FontAwesomeIcons.volumeLow, size: 30), 
                                    onPressed: (){
                                      if (nearbyParentsProvider.kidSelected!.volume >= 0.0){
                                        nearbyParentsProvider.kidSelected!.volume = nearbyParentsProvider.kidSelected!.volume - 0.1;
                                        fcpNearbyService.sendMessage(
                                          nearbyParentsProvider.kidSelected!.deviceId!, 
                                          CommandData(
                                            command: CommandType.volume, 
                                            data: nearbyParentsProvider.kidSelected!.volume
                                          )
                                        );
                                      }
                                      if (nearbyParentsProvider.kidSelected!.volume < 0) nearbyParentsProvider.kidSelected!.volume = 0;
                                    },
                                  ),
                                  Expanded(
                                    child: Slider(
                                      min: 0.0,
                                      max: 100.0,
                                      divisions: 10,
                                      value: _parseVolumeToSlider(nearbyParentsProvider),
                                      onChanged: null
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(FontAwesomeIcons.volumeHigh, size: 30), 
                                    onPressed: (){
                                      if (nearbyParentsProvider.kidSelected!.volume <= 1.0){
                                        nearbyParentsProvider.kidSelected!.volume = nearbyParentsProvider.kidSelected!.volume + 0.1;
                                        fcpNearbyService.sendMessage(
                                          nearbyParentsProvider.kidSelected!.deviceId!, 
                                          CommandData(
                                            command: CommandType.volume, 
                                            data: nearbyParentsProvider.kidSelected!.volume
                                          )
                                        );
                                      }
                                      if (nearbyParentsProvider.kidSelected!.volume > 1.0) nearbyParentsProvider.kidSelected!.volume = 1;
                                    },
                                  )
                                ]
                              ),
                              const Divider(),
                              //2nd row:
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(FontAwesomeIcons.backward, size: 30),
                                    onPressed: () => fcpNearbyService.sendMessage(nearbyParentsProvider.kidSelected!.deviceId!, CommandData(command: CommandType.previous, data: null)),
                                  ),
                                  IconButton(
                                    icon: Icon((nearbyParentsProvider.kidSelected!.isPaused) ? Icons.play_arrow_sharp : Icons.pause_rounded, size: 30), 
                                    onPressed: (){
                                      fcpNearbyService.sendMessage(
                                        nearbyParentsProvider.kidSelected!.deviceId!, 
                                        CommandData(
                                          command: CommandType.pause,
                                          data: nearbyParentsProvider.kidSelected!.isPaused
                                        ));
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(FontAwesomeIcons.stop, size: 30), 
                                    onPressed: (){
                                      nearbyParentsProvider.kidSelected!.isPaused = false;
                                      fcpNearbyService.sendMessage(nearbyParentsProvider.kidSelected!.deviceId!, CommandData(command: CommandType.stop, data: null));
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(FontAwesomeIcons.forward, size: 30), 
                                    onPressed: ()=> fcpNearbyService.sendMessage(nearbyParentsProvider.kidSelected!.deviceId!, CommandData(command: CommandType.next, data: null)),
                                  ),
                                ]
                              ),
                              const Divider(),
                              //3th row:
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  (nearbyParentsProvider.kidSelected!.isLocked)
                                  ? IconButton(
                                      icon: const Icon(Icons.lock_open_rounded), 
                                      onPressed: (){
                                        fcpNearbyService.sendMessage(
                                          nearbyParentsProvider.kidSelected!.deviceId!, 
                                          CommandData(
                                            command: CommandType.lock,
                                            data: false
                                          ));
                                      },
                                    )
                                  : IconButton(
                                    icon: const Icon(Icons.lock_rounded, size: 30), 
                                    onPressed: (){
                                      fcpNearbyService.sendMessage(
                                        nearbyParentsProvider.kidSelected!.deviceId!, 
                                        CommandData(
                                          command: CommandType.lock,
                                          data: true
                                        ));
                                    },
                                  ),
                                IconButton(
                                  icon:  const Icon(Icons.crop_rotate, size: 30), 
                                  onPressed: ()=> fcpNearbyService.sendMessage(nearbyParentsProvider.kidSelected!.deviceId!, CommandData(command: CommandType.rotate, data: null)),
                                )
                            ]
                          ),
                        ]
                      )
                    ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    );
  }

  @override
  double get maxExtent => expandedHeight + expandedHeight / 2;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}