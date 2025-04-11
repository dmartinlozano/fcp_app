import 'package:coachmaker/coachmaker.dart';
import 'package:fcp/modules/play_list/play_list_provider.dart';
import 'package:fcp/modules/player/player_parents_provider.dart';
import 'package:fcp/widgets/fcp_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../modules/play_list/play_list_demo_widget.dart';
import '../modules/play_list/play_list_widget.dart';
import '../utils/globals.dart';
import '../utils/i18n.dart';
import '../widgets/border_page_widget.dart';
import '../widgets/coach_maker_mixin.dart';
import '../widgets/coach_point_maker_widget.dart';
import '../widgets/dialog_input_widget.dart';
import '../widgets/fcp_bottom_sheet_widget.dart';

class PlayListPage extends StatefulWidget {
  
  const PlayListPage({super.key});

  @override
  State<PlayListPage> createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> with CoachMakerMixin{

   final GlobalKey<PlayListDemoWidgetState> _playListDemoWidgetKey = GlobalKey<PlayListDemoWidgetState>();

  @override
  void initState() {
    super.initState();
    showCoachMark = preferencesService.showCoachMakerPlayList;
  }

  @override
  List<CoachModel> getCoachModels() {
    return [
      CoachModel(
        initial: '21',
        title: I18n.translate('playlist_coach_mark.text1'),
        subtitle: [
          I18n.translate('playlist_coach_mark.text2')
        ],
        nextOnTapCallBack:() async {
          _playListDemoWidgetKey.currentState!.openSlidable();
          return true;
        },
      ),
      CoachModel(
        initial: '22',
        title: I18n.translate('playlist_coach_mark.text3'),
        subtitle: [
          I18n.translate('playlist_coach_mark.text4')
        ]),
      CoachModel(
        initial: '23',
        title: I18n.translate('playlist_coach_mark.text5'),
        subtitle: [
          I18n.translate('playlist_coach_mark.text6')
        ],
        nextOnTapCallBack:() async {
          _playListDemoWidgetKey.currentState!.closeSlidable();
          return true;
        },
      ),
      CoachModel(
        initial: '24',
        title: I18n.translate('playlist_coach_mark.text7'),
        subtitle: [
          I18n.translate('playlist_coach_mark.text8')
        ]
      ),
      CoachModel(
        initial: '25',
        title: I18n.translate('playlist_coach_mark.text9'),
        subtitle: [
          I18n.translate('playlist_coach_mark.text10')
        ],
        nextOnTapCallBack: () async{
          preferencesService.showCoachMakerPlayList = false;
          navigate(routeName: "/settings_page");
          return true;
        }
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlayListProvider, PlayerParentsProvider>(
      builder: (BuildContext context, playListProvider, playerParentsProvider, _) {
        return Scaffold(
          appBar: FcpAppBar(
            title: I18n.translate('playlist.title'),
            onPressed: ()=> navigate(routeName: "/settings_page"),
            showCircularProgress: playListProvider.isProcessing
          ),
          body: BorderPageWidget(
            alignment: Alignment.topCenter,
            child: (showCoachMark) 
            ? PlayListDemoWidget(
                  key: _playListDemoWidgetKey,
                )
            : playListProvider.playList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(I18n.translate('playlist.empty'), textAlign: TextAlign.center)
                      )
                    ]
                  )
                )
              : PlayListWidget(
                  list: playListProvider.playList,
                  mode: PlayListMode.edit,
                )
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton: CoachPointMakerWidget(
            initial: '21',
            showCoachPoint: showCoachMark,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              child: SpeedDial(
                icon: Icons.add,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                animatedIcon: AnimatedIcons.menu_close,
                children: [
                  SpeedDialChild(
                    child: const FaIcon(FontAwesomeIcons.photoFilm),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    label: I18n.translate('playlist.add_local_files'),
                    onTap: () {
                      if (playerParentsProvider.folderSelected != null){
                        playListService.addLocalFile();
                      }else{
                        FcpBottomSheetWidget bs = FcpBottomSheetWidget(
                          title: Text(I18n.translate('playlist.folder_unselected')),
                          acceptText: (I18n.translate('accept')),
                          acceptOnPress: () => Navigator.of(navigatorKey.currentContext!).pop()
                        );
                        bs.show();
                      }
                    },
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.playlist_add),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    label: I18n.translate('playlist.create_playlist'),
                    onTap: () => DialogInputWidget(
                      acceptText: I18n.translate('accept'),
                      cancelText: I18n.translate('cancel'),
                      hintText: I18n.translate("playlist.new_playlist"),
                      acceptOnPress: (String text) => playListService.addFolder(text),
                      cancelOnPress: () => Navigator.of(navigatorKey.currentContext!).pop()
                    ).show(),
                  ),
                  SpeedDialChild(
                    child: const Icon(Icons.drive_folder_upload_rounded),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    label: I18n.translate('playlist.import_folder'),
                    onTap: () => playListService.importFolder()
                  ),
                ]
              ),
            ),
          )
        );
      }
    );
  }
}