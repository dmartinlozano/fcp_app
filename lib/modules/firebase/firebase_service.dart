import 'package:fcp/utils/globals.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../../firebase_options.dart';

class FirebaseService{
  
  static FirebaseApp? app;

  init() async {
    //Configure and init firebase
    WidgetsFlutterBinding.ensureInitialized();
    app = await Firebase.initializeApp(name: '[DEFAULT]',options: DefaultFirebaseOptions.currentPlatform);
    FirebaseAuth.instance.setLanguageCode(preferencesService.localeS);
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
  }
}