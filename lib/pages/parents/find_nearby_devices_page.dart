import 'dart:io';  
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../modules/fcp_nearby/providers/nearby_parents_provider.dart';
import '../../modules/fcp_nearby/nearby_widget.dart';
import '../../utils/globals.dart';
import '../../utils/i18n.dart';
import '../../widgets/border_page_widget.dart';
import '../../widgets/fcp_app_bar.dart';
import '../../widgets/fcp_bottom_sheet_widget.dart';

class FindNearbyDevicesPage extends StatefulWidget {
  
  const FindNearbyDevicesPage({super.key});

  @override
  State<FindNearbyDevicesPage> createState() => _FindNearbyDevicesPageState();
}

class _FindNearbyDevicesPageState extends State<FindNearbyDevicesPage> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fcpNearbyService.stop();
      await fcpNearbyService.init(isParentMode: true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NearbyParentsProvider>(
      builder: (context, nearbyParentsProvider, child) {
        return Scaffold(
          appBar: FcpAppBar(
            title: Platform.isAndroid ? I18n.translate('dashboard_parents.title_android') : I18n.translate('dashboard_parents.title_iphone'),
            showCircularProgress: true,
            onPressed: () async {
              await fcpNearbyService.stop();
              navigate(routeName: '/dashboard_page');
            }
          ),
          body: BorderPageWidget(
            alignment: Alignment.topCenter,
            child: nearbyParentsProvider.kidsDevices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Platform.isAndroid
                      ? Text(I18n.translate('dashboard_parents.android_devices_not_found'), textAlign: TextAlign.center)
                      : Text(I18n.translate('dashboard_parents.iphone_devices_not_found'), textAlign: TextAlign.center)
                    ]
                  )
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: nearbyParentsProvider.kidsDevices.length,
                  itemBuilder: (_, int i){
                    return Column(
                      children: [
                        ListTile(
                          leading: NearbyWidget(nearbyRemoteDevice: nearbyParentsProvider.kidsDevices[i]),
                          title: Text(nearbyParentsProvider.kidsDevices[i].deviceName!, overflow: TextOverflow.ellipsis),
                          onTap: () async {
                            PackageInfo packageInfo = await PackageInfo.fromPlatform();
                            int numBuilder = int.parse(packageInfo.buildNumber);
                            if (nearbyParentsProvider.kidsDevices[i].nearbyState == SessionState.notConnected){
                              fcpNearbyService.invitePeer(nearbyParentsProvider.kidsDevices[i]);
                            }
                            if (nearbyParentsProvider.kidsDevices[i].nearbyState == SessionState.connected){
                              if(nearbyParentsProvider.kidsDevices[i].numBuilder == null || nearbyParentsProvider.kidsDevices[i].numBuilder != numBuilder){
                                FcpBottomSheetWidget bs = FcpBottomSheetWidget(
                                  title: Text(I18n.translate('dashboard_parents.device_not_version')),
                                  acceptText: (I18n.translate('accept')),
                                  acceptOnPress: (){
                                    nearbyParentsProvider.kidsDevices.setSelected(i);
                                    navigate(routeName: '/player_parents_page');
                                  }
                                );
                                bs.show();
                              }else{
                                nearbyParentsProvider.kidsDevices.setSelected(i);
                                navigate(routeName: '/player_parents_page');
                              }
                            }
                          },
                          trailing: (nearbyParentsProvider.kidsDevices[i].nearbyState == SessionState.connecting) 
                          ? null
                          : const FaIcon(FontAwesomeIcons.chevronRight, size: 15.0),
                        ),
                        const Divider()
                      ],
                    );
                  }
              ),
          )
        );
      }
    );
  }
}