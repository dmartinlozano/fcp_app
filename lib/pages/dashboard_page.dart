import 'package:coachmaker/coachmaker.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:fcp/modules/connectivity/location/location_provider.dart';
import 'package:fcp/modules/fcp_nearby/providers/nearby_kids_provider.dart';
import 'package:fcp/widgets/border_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../modules/connectivity/bluetooth/bluetooth_provider.dart';
import '../modules/connectivity/bluetooth/bluetooth_widget.dart';
import '../modules/connectivity/location/location_widget.dart';
import '../modules/firebase/firebase_provider.dart';
import '../modules/play_list/play_list_provider.dart';
import '../modules/play_list/play_list_widget.dart';
import '../utils/globals.dart';
import '../utils/i18n.dart';
import '../widgets/coach_point_maker_widget.dart';
import '../widgets/coach_maker_mixin.dart';
import '../widgets/fcp_bottom_sheet_widget.dart';

class DashboardPage extends StatefulWidget{

  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with CoachMakerMixin{

  BluetoothProvider bluetoothProvider = Provider.of<BluetoothProvider>(navigatorKey.currentContext!, listen: false);
  LocationProvider locationProvider = Provider.of<LocationProvider>(navigatorKey.currentContext!, listen: false);
  FirebaseProvider firebaseProvider = Provider.of<FirebaseProvider>(navigatorKey.currentContext!, listen: false);

  @override
  void initState() {
    super.initState();
    showCoachMark = preferencesService.showCoachMakerDashboard;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await playerService.stop();
      await playListService.init();
      firebaseAuthService.init();
      await analyticsService.init();
      await orientationService.init();
      await volumeService.init();
      await fcpNearbyService.stop();
      await fcpNearbyService.init(isParentMode: false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fcpNearbyService.stop();
      super.dispose();
    });
  }

  @override
  List<CoachModel> getCoachModels() {
    return [
      CoachModel(
        initial: '11',
        title: I18n.translate('dashboard_coach_mark.text1'),
        subtitle: [
          I18n.translate('dashboard_coach_mark.text21'),
          I18n.translate('dashboard_coach_mark.text22')
        ]),
      CoachModel(
        initial: '12',
        title: I18n.translate('dashboard_coach_mark.text3'),
        subtitle: [
          I18n.translate('dashboard_coach_mark.text4')
        ]),
      CoachModel(
        initial: '13',
        title: I18n.translate('dashboard_coach_mark.text5'),
        subtitle: [
          I18n.translate('dashboard_coach_mark.text6')
        ],
        nextOnTapCallBack: () async{
          preferencesService.showCoachMakerDashboard = false;
          return true;
        }
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<BluetoothProvider, LocationProvider, NearbyKidsProvider>(
      builder: (context, bluetoothProvider, locationProvider, nearbyKidsProvider, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            elevation: 0,
            leading: CoachPointMakerWidget(
              showCoachPoint: showCoachMark,
              initial: '11',
              child: Row(
                children: [
                  BluetoothWidget(),
                  LocationWidget(),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Badge.count(
                      count: nearbyKidsProvider.parentDevices.length,
                      backgroundColor: Colors.blueAccent,
                      alignment: Alignment.topCenter,
                      offset: const Offset(25, -5),
                      child: const FaIcon(
                        FontAwesomeIcons.networkWired,
                        size: 20.0,
                      ),
                    ),
                  )
              ]),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.crop_rotate), 
                onPressed: ()=> orientationService.rotate(),
              ),
              CoachPointMakerWidget(
                showCoachPoint: showCoachMark,
                initial: '12',
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.gear),
                  onPressed: () async {
                    if (await localAuthService.authenticate()) {
                      navigate(routeName: '/settings_page');
                    }
                  }
                ),
              ),
              CoachPointMakerWidget(
                showCoachPoint: showCoachMark,
                initial: '13',
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/controller.svg',
                    width: 25,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).iconTheme.color!,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () async {
                    bool connection = await DataConnectionChecker().hasConnection;
                    if (!await localAuthService.authenticate()) return;
                    if (firebaseProvider.user == null) {
                      if (connection){
                        await navigate(routeName: "/login_page");
                      }else{
                        FcpBottomSheetWidget bs = FcpBottomSheetWidget(
                          title: Text(I18n.translate('connectivity.mobile_data_text')),
                          acceptText: (I18n.translate('accept')),
                          acceptOnPress: () => Navigator.of(navigatorKey.currentContext!).pop()
                        );
                        bs.show();
                      }
                      if (firebaseProvider.user == null) return;
                    }
                    if (firebaseProvider.purchase == null) {
                      await navigate(routeName: '/purchase_page');
                      if (firebaseProvider.purchase == null) return;
                    }
                    if (!bluetoothProvider.isValid() || !(await locationProvider.isValid())) {
                      await navigate(routeName: "/connectivity_page");
                      if (!bluetoothProvider.isValid() && !(await locationProvider.isValid())) return;
                    }
                    await navigate(routeName: '/find_nearby_devices_page');
                  }
                ),
              ),
            ],
          ),
          body: Consumer<PlayListProvider>(
            builder: (BuildContext context, playListProvider, _) {
              return BorderPageWidget(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        child: Image.asset(
                          "assets/images/waiting.gif",
                        )
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                        child: playListProvider.playList.isEmpty
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
                            mode: PlayListMode.view,
                          )
                      )
                  ]
                ),
              );
            }
          )
        );
      }
    );
  }

}