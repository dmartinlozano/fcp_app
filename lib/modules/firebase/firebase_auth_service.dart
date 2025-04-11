import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../utils/globals.dart';
import 'firebase_dao.dart';
import 'firebase_provider.dart';

class FirebaseAuthService {

  FirebaseProvider firebaseProvider = Provider.of<FirebaseProvider>(navigatorKey.currentContext!, listen: false);

  init() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      await _readPuchase(user);
    });
    FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
      await _readPuchase(user);
    });
    FirebaseAuth.instance.userChanges().listen((User? user) async {
      await _readPuchase(user);
    });
  }

  _readPuchase(User? user) async{
    if (user == null){
      firebaseProvider.user = null;
      firebaseProvider.purchase = null;
    }else if (user.email == null){
      firebaseProvider.user = null;
      firebaseProvider.purchase = null;
    }else{
      firebaseProvider.user = user;
      purchaseService.init();
      try{
        firebaseProvider.purchase = await FirebaseDao.readPurchases();
      } on Exception catch(e) {
        firebaseProvider.purchase = null;
        FirebaseDao.writeException(TypeException.readPurchase, e);
      }
    }
  }

  deleteUser() async {
    await FirebaseDao.deleteUser();
  }

  Future<bool> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    if (googleAuth != null){
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential user = await FirebaseAuth.instance.signInWithCredential(credential);
      firebaseProvider.user = user.user;
      return true;
    }
    return false;
  }

  Future<bool> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    if (loginResult.accessToken != null){
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
      UserCredential user = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
      firebaseProvider.user = user.user;
      return true;
    }
    return false;
  }

  Future<bool> signInWithMicrosoft() async{
    UserCredential user = await FirebaseAuth.instance.signInWithProvider(MicrosoftAuthProvider());
    firebaseProvider.user = user.user;
    return true;
  }

  Future<bool> signInWithApple() async {
    final appleProvider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithProvider(appleProvider);
    firebaseProvider.user = userCredential.user;
    return true;
  }

  Future<void> signOut() async {
    late FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth.signOut();
    await GoogleSignIn().signOut();
  }
}
