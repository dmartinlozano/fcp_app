import 'package:fcp/utils/globals.dart';
import 'package:fcp/widgets/border_page_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/i18n.dart';
import '../widgets/fcp_app_bar.dart';
import '../widgets/fcp_bottom_sheet_widget.dart';
import '../widgets/outlined_button_ext.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  loginOK(){
    analyticsService.login();
    FcpBottomSheetWidget bs = FcpBottomSheetWidget(
      title: Text(I18n.translate('login.login_ok')),
      acceptText: (I18n.translate('accept')),
      acceptOnPress: () => Navigator.of(navigatorKey.currentContext!).pop(true)
    );
    bs.show();
  }

  loginKO(Exception e){
    if (kDebugMode) print(e);
    FcpBottomSheetWidget bs = FcpBottomSheetWidget(
      title: Text(I18n.translate('error.login')),
      acceptText: (I18n.translate('accept')),
      acceptOnPress: () => Navigator.of(navigatorKey.currentContext!).pop(false)
    );
    bs.show();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FcpAppBar(
          title: I18n.translate('settings.login'),
          onPressed: () => Navigator.of(navigatorKey.currentContext!).pop(false),
        ),
        body: BorderPageWidget(
          alignment: Alignment.center,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: OutlinedButtonExt(
                    title: Text(I18n.translate('login.google'), style: const TextStyle(color: Colors.black)),
                    icon: const FaIcon(FontAwesomeIcons.google, size: 25, color: Colors.blue),
                    textColor: Colors.white,
                    onPressed: () async {
                      try{
                        bool logisOk = await firebaseAuthService.signInWithGoogle();
                        (logisOk) ? loginOK() : loginKO(Exception());
                      } on Exception catch(e){
                        loginKO(e);
                      }
                    },
                  )
                ),
                Flexible(
                  child: OutlinedButtonExt(
                    title: Text(I18n.translate('login.facebook'), style: const TextStyle(color: Colors.black)),
                    icon: const FaIcon(FontAwesomeIcons.facebookF, size: 25, color: Colors.blue),
                    textColor: Colors.white,
                    onPressed: () async {
                      try{
                        bool logisOk = await firebaseAuthService.signInWithFacebook();
                        (logisOk) ? loginOK() : loginKO(Exception());
                      } on Exception catch(e){
                        loginKO(e);
                      }
                    }
                  )
                ),
                Flexible(
                  child: OutlinedButtonExt(
                    title: Text(I18n.translate('login.apple'), style: const TextStyle(color: Colors.black)),
                    icon: const FaIcon(FontAwesomeIcons.apple, size: 25, color: Colors.blue),
                    textColor: Colors.white,
                    onPressed: () async {
                      try{
                        bool logisOk = await firebaseAuthService.signInWithApple();
                        (logisOk) ? loginOK() : loginKO(Exception());
                      loginOK();
                      } on Exception catch(e){
                        loginKO(e);
                      }
                    }
                  )
                ),
                Flexible(
                  child: OutlinedButtonExt(
                    title: Text(I18n.translate('login.microsoft'), style: const TextStyle(color: Colors.black)),
                    icon: const FaIcon(FontAwesomeIcons.microsoft, size: 25, color: Colors.blue),
                    textColor: Colors.white,
                    onPressed: () async {
                      try{
                        bool logisOk = await firebaseAuthService.signInWithMicrosoft();
                        (logisOk) ? loginOK() : loginKO(Exception());
                      loginOK();
                      } on Exception catch(e){
                        loginKO(e);
                      }
                    }
                  )
                ),
              ],
            ),
          ),
          )
    );
  }
}
