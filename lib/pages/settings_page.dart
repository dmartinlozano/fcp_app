import 'package:app_settings/app_settings.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:fcp/modules/dark_mode/dark_mode_provider.dart';
import 'package:fcp/modules/firebase/firebase_provider.dart';
import 'package:fcp/widgets/dialog_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/globals.dart';
import '../utils/i18n.dart';
import '../widgets/border_page_widget.dart';
import '../widgets/fcp_app_bar.dart';
import '../widgets/fcp_bottom_sheet_widget.dart';

class SettingsPage extends StatefulWidget {

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool isLocalAuthSupported = false;
  bool internetConnection = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    bool supported = await localAuthService.auth.isDeviceSupported();
    bool connection = await DataConnectionChecker().hasConnection;
    setState(() {
      isLocalAuthSupported = supported;
      internetConnection = connection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FcpAppBar(
        title: I18n.translate('settings.title'),
        onPressed: ()=> navigate(routeName: "/dashboard_page"),
      ),
      body: Consumer2<FirebaseProvider, DarkModeProvider>(
        builder: (_, firebaseProvider, darkModeProvider, __) {
          return BorderPageWidget(
              alignment: Alignment.topCenter,
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: ListTile.divideTiles(
                  context: context,
                  tiles: [
                    Visibility(
                      visible: firebaseProvider.user == null && internetConnection == true,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(0.5),
                          title: Text(I18n.translate('settings.login')),
                          leading: const FaIcon(FontAwesomeIcons.rightToBracket),
                          onTap: () => navigate(routeName: "/login_page"),
                          trailing: const Icon(Icons.chevron_right_rounded),
                        )
                      ),
                    ),
                    Visibility(
                      visible: firebaseProvider.user != null,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(0.5),
                          title: Text(I18n.translate('settings.logout')),
                          leading: const FaIcon(FontAwesomeIcons.rightToBracket),
                          onTap: () async {
                            await firebaseAuthService.signOut();
                            analyticsService.logout();
                            FcpBottomSheetWidget bs = FcpBottomSheetWidget(
                              title: Text(I18n.translate('login.logout_ok')),
                              acceptText: (I18n.translate('accept')),
                              acceptOnPress: () {
                                Navigator.of(navigatorKey.currentContext!).pop();
                                firebaseProvider.user = null;
                                firebaseProvider.purchase = null;
                              }
                            );
                            bs.show();
                          },
                          trailing: const Icon(Icons.chevron_right_rounded),
                        )
                      ),
                    ),
                    Visibility(
                      visible: firebaseProvider.user != null,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(0.5),
                          title: Text(I18n.translate('settings.my_account')),
                          leading: const FaIcon(FontAwesomeIcons.solidUser),
                          onTap: () => navigate(routeName: "/my_account_page"),
                          trailing: const Icon(Icons.chevron_right_rounded),
                        )
                      ),
                    ),
                    Visibility(
                      visible: firebaseProvider.user != null && firebaseProvider.purchase == null && internetConnection == true,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(0.5),
                          title: Text(I18n.translate('settings.premium')),
                          leading: const FaIcon(FontAwesomeIcons.cartShopping),
                          onTap: () => navigate(routeName: "/purchase_page"),
                          trailing: const Icon(Icons.chevron_right_rounded),
                        )
                      ),
                    ),
                    Visibility(
                      visible: firebaseProvider.user != null && firebaseProvider.purchase != null && preferencesService.restorePurchase == null,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(0.5),
                          title: Text(I18n.translate('settings.restore_purchase')),
                          leading: const FaIcon(FontAwesomeIcons.cartShopping),
                          onTap: (){
                            FcpBottomSheetWidget bs = FcpBottomSheetWidget(
                              title: Text(I18n.translate('settings.restore_purchase_text')),
                              acceptText: (I18n.translate('accept')),
                              acceptOnPress: (){
                                preferencesService.restorePurchase = false;
                                Navigator.of(navigatorKey.currentContext!).pop();
                              }
                            );
                            bs.show();
                          },
                          trailing: const Icon(Icons.chevron_right_rounded),
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0.5),
                        title: Row(children: [
                          Text(I18n.translate('settings.playlist'))
                        ]),
                        leading: Icon(Icons.queue_music),
                        onTap: () => navigate(routeName: '/play_list_page'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0.5),
                        title: Text(I18n.translate('settings.dark_mode')),
                        leading: const FaIcon(FontAwesomeIcons.solidLightbulb),
                        onTap: null,
                        trailing: Switch(
                          value: preferencesService.enabledDarkMode ?? false, 
                          onChanged: (bool newValue) {
                            darkModeProvider.enabledDarkMode = newValue;
                          },
                        ),
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0.5),
                        title: Text(I18n.translate('settings.custom_name')),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => DialogInputWidget(
                          acceptText: I18n.translate('accept'),
                          cancelText: I18n.translate('cancel'),
                          hintText: preferencesService.customName,
                          acceptOnPress: (String text){
                            preferencesService.customName = text;
                          },
                          cancelOnPress: () => Navigator.of(navigatorKey.currentContext!).pop()
                        ).show(),
                        leading: const FaIcon(FontAwesomeIcons.signature),
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0.5),
                        title: Text(I18n.translate('settings.language')),
                        leading: const FaIcon(FontAwesomeIcons.globe),
                        trailing: DropdownButton<String>(
                          value: I18n.getLocale().languageCode,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          elevation: 16,
                          onChanged: (String? localeValueSelected) async {
                            Locale localeSelected = I18n.supportedLocales.firstWhere((locale) => locale.languageCode == localeValueSelected);
                            await I18n.load(localeSelected);
                            setState(() => preferencesService.localeS = localeSelected.languageCode);
                          },
                          items: I18n.supportedLocales.map<DropdownMenuItem<String>>((Locale locale) =>DropdownMenuItem<String>(
                            value: locale.languageCode,
                            child: Text(I18n.translate('languagues.${locale.languageCode}'))
                          )).toList()
                        )
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0.5),
                        title: Text(I18n.translate('settings.settings_ios')),
                        leading: Icon(Icons.app_settings_alt_outlined),
                        onTap: () async  => await AppSettings.openAppSettings(asAnotherTask: true),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      )
                    ),
                    Visibility(
                      visible: isLocalAuthSupported == false,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(0.5),
                          title: Text(I18n.translate('settings.control_parental')),
                          leading: Icon(Icons.key),
                          onTap: () async => FcpBottomSheetWidget(
                            title: Text(I18n.translate('settings.control_parental_change')),
                            acceptText: (I18n.translate('accept')),
                            acceptOnPress: () async{
                              Navigator.of(navigatorKey.currentContext!).pop();
                              preferencesService.pin = null;
                              await localAuthService.authenticate();
                            },
                          ).show(),
                          trailing: const Icon(Icons.chevron_right_rounded),
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0.5),
                        title: Text(I18n.translate('settings.privacy_policy')),
                        leading: Icon(Icons.shield),
                        onTap: () async => await launchUrl(Uri.parse("https://familycarplayer.github.io/privacy_policy")),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      )
                    ),
                    Visibility(
                      visible: firebaseProvider.user != null,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(0.5),
                          title: Text(I18n.translate('settings.delete_user')),
                          leading: const FaIcon(FontAwesomeIcons.userMinus),
                          onTap: () {
                            FcpBottomSheetWidget bs1 = FcpBottomSheetWidget(
                              title: Text(I18n.translate('settings.delete_user_title')),
                              subtitle: Text(I18n.translate((firebaseProvider.purchase == null) ? 'settings.delete_user_no_purchase' : 'settings.delete_user_purchase')),
                              acceptText: I18n.translate('accept'),
                              acceptOnPress: () async {
                                Navigator.of(navigatorKey.currentContext!).pop();
                                bool isAuth = await localAuthService.authenticate();
                                if (isAuth){
                                  await firebaseAuthService.deleteUser();
                                  FcpBottomSheetWidget bs2 = FcpBottomSheetWidget(
                                    title: Text(I18n.translate('settings.delete_user_done')),
                                    acceptText: I18n.translate('accept'),
                                    acceptOnPress: () async {
                                      Navigator.of(context).pop(false);
                                      await firebaseAuthService.signOut();
                                      analyticsService.userDeleted();
                                      firebaseProvider.user = null;
                                      firebaseProvider.purchase = null;
                                    }
                                  );
                                  bs2.show();
                                }
                              },
                              cancelText: I18n.translate('cancel'),
                              cancelOnPress: ()=>Navigator.of(context).pop(false)
                            );
                            bs1.show();
                          },
                          trailing: const Icon(Icons.chevron_right_rounded),
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0.5),
                        title: Row(children: [
                          Text(I18n.translate('help'))
                        ]),
                        leading: const FaIcon(FontAwesomeIcons.solidCircleQuestion),
                        onTap: () => navigate(routeName: '/help_page'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      )
                    ),
                    (version == null) ? Container() : SizedBox(width: double.infinity, child: Text(version!, textAlign: TextAlign.right))
                  ]
                ).toList()
              ),
          );
        }
      )
    );
  }
}
