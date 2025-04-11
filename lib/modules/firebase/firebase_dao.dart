
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import '../../utils/globals.dart';
import '../purchase/purchase_dto.dart';
import 'firebase_provider.dart';
import 'firebase_service.dart';

enum TypeException{
  readPurchase,
  writePurchase,
  doPurchase,
  login
}

extension ParseTEToString on TypeException {
  String value() {
    return toString().split('.').last;
  }
}

class FirebaseDao {

  static FirebaseProvider firebaseProvider = Provider.of<FirebaseProvider>(navigatorKey.currentContext!, listen: false);

  static Future<PurchaseDto?> readPurchases() async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        FirebaseApp? app = FirebaseService.app;
        DatabaseReference database = FirebaseDatabase.instanceFor(app: app!).ref();
        database.keepSynced(true);
        String? email = encodeFirebaseName(firebaseProvider.user!.email);
        DatabaseEvent data = await database.child(email!).child("purchase").once();
        if (data.snapshot.value == null) {
          return null;
        } else {
          return PurchaseDto.fromJson(data.snapshot.value as Map);
        }
      } catch (e) {
        return null;
      }
    }else{
      return null;
    }
  } 

  static void writePurchase(PurchaseDto purchase) async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        FirebaseApp? app = FirebaseService.app;
        DatabaseReference database = FirebaseDatabase.instanceFor(app: app!).ref();
        database.keepSynced(true);
        String? email = encodeFirebaseName(firebaseProvider.user!.email);
        database.child(email!).child("purchase").set(purchase.toJson());
      } catch (e) {
        rethrow;
      }
    }else{
      return null;
    } 
  }

  static void writeError(TypeException typeException, IAPError? error) async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        FirebaseApp? app = FirebaseService.app;
        DatabaseReference database = FirebaseDatabase.instanceFor(app: app!).ref();
        database.keepSynced(true);
        String? email = encodeFirebaseName(firebaseProvider.user!.email);
        database.child(email!).child("exceptions").child(typeException.name).set(error);
      } catch (e) {
        return;
      }
    }else{
      null;
    }
  }

  static void writeException(TypeException typeException, Exception e) async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        FirebaseApp? app = FirebaseService.app;
        DatabaseReference database = FirebaseDatabase.instanceFor(app: app!).ref();
        database.keepSynced(true);
        String? email = encodeFirebaseName(firebaseProvider.user!.email);
        database.child(email!).child("exceptions").child(typeException.name).set(e.toString());
      } catch (e) {
        return;
      }
    }else{
      null;
    }
  }

  static Future<void> deleteUser() async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        FirebaseApp? app = FirebaseService.app;
        DatabaseReference database = FirebaseDatabase.instanceFor(app: app!).ref();
        database.keepSynced(true);
        String? email = encodeFirebaseName(firebaseProvider.user!.email);
        await database.child(email!).remove();
      } catch (e) {
        rethrow;
      }
    }
  } 
}
