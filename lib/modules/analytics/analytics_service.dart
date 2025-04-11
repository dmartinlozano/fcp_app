import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import '../../utils/globals.dart';
import '../fcp_nearby/providers/nearby_kids_provider.dart';
import '../fcp_nearby/providers/nearby_parents_provider.dart';
import '../firebase/firebase_provider.dart';

enum AnalyticErrors{
  purchaseNotAvailable,
  purchaseProductsAreEmpty,
  purchaseDetailsAreEmpty,
  purchaseError
}

class AnalyticsService {

  FirebaseProvider firebaseProvider = Provider.of<FirebaseProvider>(navigatorKey.currentContext!, listen: false);
  NearbyParentsProvider nearbyParentsProvider = Provider.of<NearbyParentsProvider>(navigatorKey.currentContext!, listen: false);
  NearbyKidsProvider nearbyKidsProvider = Provider.of<NearbyKidsProvider>(navigatorKey.currentContext!, listen: false);
  Map<String, Object> parameters = {};

  init() async {
    AndroidDeviceInfo? androidDeviceInfo;
    IosDeviceInfo? iosDeviceInfo;
    if (Platform.isAndroid) {
      androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
      parameters['platform'] = 'android';
      parameters['manufacturer'] = androidDeviceInfo.manufacturer;
      parameters['model'] = androidDeviceInfo.model;
      parameters['release'] = androidDeviceInfo.version.release;
      parameters['isPhysicalDevice'] = androidDeviceInfo.isPhysicalDevice ? "true" : "false";
    } else {
      iosDeviceInfo = await DeviceInfoPlugin().iosInfo;
      parameters['platform'] = 'ios';
      parameters['manufacturer'] = iosDeviceInfo.identifierForVendor!;
      parameters['model'] = iosDeviceInfo.model;
      parameters['systemName'] = iosDeviceInfo.systemName;
      parameters['systemVersion'] = iosDeviceInfo.systemVersion;
      parameters['isPhysicalDevice'] = iosDeviceInfo.isPhysicalDevice ? "true" : "false";
    }
    if (firebaseProvider.user == null) {
      parameters['email'] = "";
    } else {
      parameters['email'] = firebaseProvider.user!.email!;
      if (firebaseProvider.purchase == null){
        parameters['purchase'] = "";
      }else{
        parameters['purchase'] = jsonEncode(firebaseProvider.purchase!.toJson());
      }
    }
    parameters['production'] = kReleaseMode ? "true" : "false";
    parameters['version'] = version!;
    parameters['country'] = PlatformDispatcher.instance.locale.countryCode!;

    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
  }

  log(String currentRoute) {
    currentRoute = currentRoute.replaceAll("/", "");
    if (parameters.isNotEmpty) {
      FirebaseAnalytics.instance.logEvent(
        name: currentRoute,
        parameters: parameters,
      );
    }
  }

  nearbyLog(bool isParentMode){
    if (isParentMode){
      parameters["devicesConnected"] = nearbyParentsProvider.kidsDevices.length;
    }else{
      parameters["devicesConnected"] = nearbyKidsProvider.parentDevices.length;
    }
  }

  login(){
    if (firebaseProvider.user != null){
      FirebaseAnalytics.instance.setUserId(
        id: firebaseProvider.user!.email
      );
    }
  }

  logout(){
    FirebaseAnalytics.instance.setUserId(
      id: ""
    );
  }

  userDeleted(){
    FirebaseAnalytics.instance.setUserId(id: "");
    FirebaseAnalytics.instance.logEvent(
      name: "user_deleted",
      parameters: parameters,
    );
  }

  viewPurchase(){
    FirebaseAnalytics.instance.logEvent(
      name: "view_item"
    );
  }

  beginPurchase(){
    FirebaseAnalytics.instance.logEvent(
      name: "begin_checkout"
    );
  }


  paymentInfo(){
    if (firebaseProvider.productsAvailable.isNotEmpty){
      for (ProductDetails productDetails in firebaseProvider.productsAvailable){
        FirebaseAnalytics.instance.logAddPaymentInfo(
          currency: productDetails.currencyCode,
          value: productDetails.rawPrice, 
        );
      }
    }
  }

  pay(){
    if (firebaseProvider.purchase != null){
      FirebaseAnalytics.instance.logPurchase(
        transactionId: firebaseProvider.purchase!.purchaseID,
        items: [
          AnalyticsEventItem(
            itemCategory2: firebaseProvider.purchase!.status.toString()
          )
        ]
      );
    }
  }

  error(AnalyticErrors error){
    parameters["error"] = error.toString();
    FirebaseAnalytics.instance.logEvent(
      name: "purchase_error",
      parameters: parameters,
    );
  }


}
