import 'package:fcp/modules/fcp_nearby/providers/nearby_parents_provider.dart';
import 'package:fcp/widgets/fcp_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modules/play_list/play_list_controller_widget.dart';
import '../../modules/play_list/play_list_widget.dart';
import '../../modules/player/player_parents_provider.dart';
import '../../utils/globals.dart';
import '../../utils/i18n.dart';
import '../../widgets/border_page_widget.dart';

class PlayerParentsPage extends StatefulWidget {

  const PlayerParentsPage({super.key});

  @override State<PlayerParentsPage> createState() => _PlayerParentsPageState();
}

class _PlayerParentsPageState extends State<PlayerParentsPage> {

  PlayerParentsProvider playerParentsProvider = Provider.of<PlayerParentsProvider>(navigatorKey.currentContext!, listen: false);
  bool isAlreadyDispose =  false;

  @override
  void dispose() {
    if (!isAlreadyDispose){
      super.dispose();
      playerParentsProvider.folderSelected = null;
      playerParentsProvider.mediaSelected = null;
      isAlreadyDispose = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FcpAppBar(),
      body: Consumer<NearbyParentsProvider>(
        builder: (context, nearbyParentsProvider, child) {
          if (nearbyParentsProvider.kidSelected == null){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              dispose();
              if (currentRoute == '/player_parents_page'){
                navigate(routeName: '/find_nearby_devices_page');
              }
            });
          }else if (nearbyParentsProvider.kidSelected != null && nearbyParentsProvider.kidSelected!.playList.isEmpty){
            return BorderPageWidget(
              alignment: Alignment.center,
              child: Text(I18n.translate('player.empty'), textAlign: TextAlign.center)
            );
          }else{
            return CustomScrollView(
              slivers: <Widget>[
                SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: PlayListControllerWidget(
                    expandedHeight: 200,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 0.0, bottom: 0.0),
                      child: PlayListWidget(
                        list: nearbyParentsProvider.kidSelected!.playList,
                        mode: PlayListMode.view,
                      ),
                    ),
                  ),
                )
              ],
            );
          }
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
      )
    );
  }
}

      