
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../modules/play_list/dto/folder_dto.dart';
import '../modules/play_list/dto/media_dto.dart';
import '../modules/play_list/play_list_provider.dart';
import '../modules/play_list/thumbnail_widget.dart';
import '../modules/player/player_kids_provider.dart';
import '../utils/globals.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {

  PlayListProvider playListProvider = Provider.of<PlayListProvider>(navigatorKey.currentContext!, listen: false);
  bool isFullScreen = true;
  bool? previousInternetConnectionEnabled;

  @override
  initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //put in landscape
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    });
    super.initState();
  }

  @override
  dispose(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Widget _videoPlayer(PlayerKidsProvider playerKidsProvider){
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => (playerKidsProvider.isLoked) ? null : setState(() => isFullScreen = !isFullScreen),
      child: Center(
        child: VideoPlayer(playerKidsProvider.playerController!)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (isFullScreen) ? null : AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => navigate(routeName: '/dashboard_page')
        ),
      ),
      backgroundColor: (isFullScreen) ? Colors.black : Colors.white,
      body: Consumer<PlayerKidsProvider>(
      builder: (context, playerProvider, _) {
        if (playerProvider.playerController == null){
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator()
              ]
            )
          );
        }
        if (isFullScreen){
          return _videoPlayer(playerProvider);
        }else{
          return Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: AspectRatio(
                  aspectRatio: playerProvider.playerController!.value.aspectRatio,
                  child: _videoPlayer(playerProvider)
                )
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      playerProvider.playerController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                    ),
                    onPressed: () => playerService.pause()
                  ),
                  Expanded(
                    child: VideoProgressIndicator(
                      playerProvider.playerController!, 
                      allowScrubbing: true
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: playListProvider.playList.expand((FolderDto folderDto) => folderDto.children).map((MediaDto mediaDto) =>
                    Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            playerService.play(mediaDto);
                            setState(() => isFullScreen = true);
                          },
                          child: ThumbnailWidget(
                            item: mediaDto,
                            isSelected: playerProvider.playingInfo != null && playerProvider.playingInfo!.uuid == mediaDto.uuid
                          )
                        ),
                        const SizedBox(width: 5)
                      ],
                    )
                  ).toList()
                ),
              )
            ]);
        }
      })
    );
  }
}
