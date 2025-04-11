import 'package:device_info_plus/device_info_plus.dart';
import 'package:fcp/modules/firebase/firebase_auth_service.dart';
import 'package:fcp/modules/firebase/firebase_service.dart';
import 'package:fcp/modules/local_auth_service.dart';
import 'package:fcp/modules/orientation_service.dart';
import 'package:fcp/modules/player/player_service.dart';
import 'package:fcp/modules/purchase/purchase_service.dart';
import 'package:fcp/modules/volume/volume_service.dart';
import 'package:flutter/material.dart';
import '../modules/analytics/analytics_service.dart';
import '../modules/fcp_nearby/fcp_nearby_service.dart';
import '../modules/play_list/play_list_service.dart';
import '../modules/preferences_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
String? currentRoute;
String? version;
BaseDeviceInfo? deviceInfo;
FcpNearbyService fcpNearbyService = FcpNearbyService();
PlayerService playerService = PlayerService();
PreferencesService preferencesService = PreferencesService();
PlayListService playListService = PlayListService();
FirebaseService firebaseService = FirebaseService();
FirebaseAuthService firebaseAuthService = FirebaseAuthService();
PurchaseService purchaseService = PurchaseService();
AnalyticsService analyticsService = AnalyticsService();
OrientationService orientationService = OrientationService();
VolumeService volumeService = VolumeService();
LocalAuthService localAuthService = LocalAuthService();

double playerControlsHeight = 200;

navigate({required String routeName}){
  currentRoute = routeName;
  analyticsService.log(routeName);
  return navigatorKey.currentState?.pushNamed(routeName);
}

String? encodeFirebaseName(String? email){
  return email?.replaceAll(".","_");
}