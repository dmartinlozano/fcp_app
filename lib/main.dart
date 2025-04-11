import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fcp/modules/connectivity/bluetooth/bluetooth_provider.dart';
import 'package:fcp/modules/volume/volume_provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'modules/connectivity/location/location_provider.dart';
import 'modules/dark_mode/dark_mode_provider.dart';
import 'modules/fcp_nearby/providers/nearby_kids_provider.dart';
import 'modules/fcp_nearby/providers/nearby_parents_provider.dart';
import 'modules/fcp_nearby/providers/nearby_provider.dart';
import 'modules/play_list/play_list_provider.dart';
import 'modules/player/player_parents_provider.dart';
import 'pages/connectivity_page.dart';
import 'pages/help_page.dart';
import 'modules/firebase/firebase_provider.dart';
import 'pages/dashboard_page.dart';
import 'pages/player_page.dart';
import 'pages/login_page.dart';
import 'pages/my_account_page.dart';
import 'pages/parents/find_nearby_devices_page.dart';
import 'pages/parents/player_parents_page.dart';
import 'pages/play_list_page.dart';
import 'pages/purchase_page.dart';
import 'pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'modules/player/player_kids_provider.dart';
import 'pages/wizard_page.dart';
import 'utils/globals.dart';
import 'utils/i18n.dart';

void main() async {

  BindingBase.debugZoneErrorsAreFatal = false;

  runZonedGuarded<Future<void>>(() async {
    
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    await preferencesService.init();
    await firebaseService.init();
    await I18n.load(I18n.getLocale());

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = '${packageInfo.version}+${packageInfo.buildNumber}';

    if (Platform.isAndroid){
      deviceInfo = await DeviceInfoPlugin().androidInfo;
    }else{
      deviceInfo = await DeviceInfoPlugin().iosInfo;
    }

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BluetoothProvider()),
          ChangeNotifierProvider(create: (_) => LocationProvider()),
          ChangeNotifierProvider(create: (_) => PlayerKidsProvider()),
          ChangeNotifierProvider(create: (_) => PlayerParentsProvider()),
          ChangeNotifierProvider(create: (_) => NearbyProvider()),
          ChangeNotifierProvider(create: (_) => NearbyParentsProvider()),
          ChangeNotifierProvider(create: (_) => NearbyKidsProvider()),
          ChangeNotifierProvider(create: (_) => FirebaseProvider()),
          ChangeNotifierProvider(create: (_) => PlayListProvider()),
          ChangeNotifierProvider(create: (_) => DarkModeProvider()),
          ChangeNotifierProvider(create: (_) => VolumeProvider()),
        ], 
        child: const FcpApp()
      )
    );
  }, (error, stack) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
  });
}

class FcpApp extends StatelessWidget {

  const FcpApp({super.key});
  static FirebaseAnalyticsObserver analyticsObserver = FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);

  @override
  Widget build(BuildContext context) {
    DarkModeProvider darkModeProvider = Provider.of<DarkModeProvider>(context);
    return OrientationBuilder(
      builder: (_, orientation) {
        orientation = orientation;
        return MaterialApp(
          debugShowCheckedModeBanner: (kReleaseMode) ? false : true,
          theme: darkModeProvider.themeData,
          navigatorKey: navigatorKey,
          initialRoute: '/',
          navigatorObservers: <NavigatorObserver>[analyticsObserver],
          onGenerateRoute: (RouteSettings settings) {
            currentRoute = settings.name;
            if (preferencesService.hideWizard == false) return PageTransition(child: const WizardPage(), type: PageTransitionType.bottomToTop);
            switch (settings.name) {
              case '/':
              case '/dashboard_page': return PageTransition(child: const DashboardPage(), type: PageTransitionType.bottomToTop);
              case '/find_nearby_devices_page': return PageTransition(child: const FindNearbyDevicesPage(), type: PageTransitionType.bottomToTop);
              case '/connectivity_page': return PageTransition(child: const ConnectivityPage(), type: PageTransitionType.bottomToTop);
              case '/player_parents_page': return PageTransition(child: const PlayerParentsPage(), type: PageTransitionType.bottomToTop);
              case '/player_page': return PageTransition(child: const PlayerPage(), type: PageTransitionType.bottomToTop);
              case '/settings_page': return PageTransition(child: const SettingsPage(), type: PageTransitionType.bottomToTop);
              case '/play_list_page': return PageTransition(child: const PlayListPage(), type: PageTransitionType.bottomToTop);
              case '/login_page': return PageTransition(child: const LoginPage(), type: PageTransitionType.bottomToTop);
              case '/purchase_page': return PageTransition(child: const PurchasePage(), type: PageTransitionType.bottomToTop);
              case '/my_account_page': return PageTransition(child: const MyAccountPage(), type: PageTransitionType.bottomToTop);
              case '/help_page': return PageTransition(child: const HelpPage(), type: PageTransitionType.bottomToTop);
            }
            return null;
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: I18n.supportedLocales,
        );
      }
    );
  }
}
