import 'dart:async';
import 'package:fcp/pages/auth_page.dart';
import 'package:fcp/utils/globals.dart';
import 'package:fcp/utils/i18n.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:page_transition/page_transition.dart';

class LocalAuthService{

  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try{
      if (await auth.isDeviceSupported()){
        return await auth.authenticate(
          localizedReason: I18n.translate('local_auth_service.scan_without_biometric'),
          options: const AuthenticationOptions(
            stickyAuth: true,
          )
        );
      }else{
        return await _requestPin();
      }
    }catch(e){
      return await _requestPin();
    }
  }

  Future<bool> _requestPin() async {
    final bool? pinResult = await Navigator.push(
      navigatorKey.currentContext!,
      PageTransition(child: const AuthPage(), type: PageTransitionType.bottomToTop)
    );
    return pinResult ?? false;
  }

}