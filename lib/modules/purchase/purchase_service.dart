import 'dart:async';
import 'dart:io';
import 'package:fcp/modules/firebase/firebase_dao.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import '../../utils/globals.dart';
import '../../utils/i18n.dart';
import '../../widgets/fcp_bottom_sheet_widget.dart';
import '../analytics/analytics_service.dart';
import '../firebase/firebase_provider.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'purchase_dto.dart';

class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}

class PurchaseService{

  FirebaseProvider firebaseProvider = Provider.of<FirebaseProvider>(navigatorKey.currentContext!, listen: false);
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool isPurchaseFinished = false;

  purchaseSuccesfull(){
    if (!isPurchaseFinished){
      isPurchaseFinished = true;
      analyticsService.pay();
      FcpBottomSheetWidget bs = FcpBottomSheetWidget(
        title: Text(I18n.translate('purchase.ok')),
        acceptText: (I18n.translate('accept')),
        acceptOnPress: () {
          Navigator.of(navigatorKey.currentContext!).pop();
          navigate(routeName: "/settings_page");
        }
      );
      bs.show();
    }
  }

  purchaseFailed(Exception e){
    if (!isPurchaseFinished){
      isPurchaseFinished = true;
      analyticsService.error(AnalyticErrors.purchaseError);
      if (kDebugMode) print(e);
      FcpBottomSheetWidget bs = FcpBottomSheetWidget(
        title: Text(I18n.translate('error.purchase_error')),
        acceptText: (I18n.translate('accept')),
        acceptOnPress: () {
          Navigator.of(navigatorKey.currentContext!).pop();
          navigate(routeName: "/settings_page");
        }
      );
      bs.show();
    }
  }

  init() async {
    isPurchaseFinished = false;

    firebaseProvider.isPurchaseAvailable = await InAppPurchase.instance.isAvailable();
    if (!firebaseProvider.isPurchaseAvailable){
      analyticsService.error(AnalyticErrors.purchaseNotAvailable);
      return;
    }
    await removePending();
    String purchaseId = (kDebugMode && Platform.isAndroid) ? 'android.test.purchased' : 'fcp_purchase';
    ProductDetailsResponse productDetailResponse = await InAppPurchase.instance.queryProductDetails(<String>{purchaseId});
    if (productDetailResponse.productDetails.isEmpty) {
      analyticsService.error(AnalyticErrors.purchaseProductsAreEmpty);
      return;
    }else{
      firebaseProvider.productsAvailable  = productDetailResponse.productDetails;
      if (Platform.isIOS){
        final transactions = await SKPaymentQueueWrapper().transactions();
        for (var transaction in transactions) { 
          await SKPaymentQueueWrapper().finishTransaction(transaction);
        }
      }
      analyticsService.paymentInfo();
    }

    final Stream<List<PurchaseDetails>> purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) async {
      if (purchaseDetailsList.isEmpty){
        purchaseFailed(Exception());
        analyticsService.error(AnalyticErrors.purchaseDetailsAreEmpty);
      }else{
        PurchaseDetails purchase = purchaseDetailsList[0];
        if (purchase.status == PurchaseStatus.error || purchase.status == PurchaseStatus.canceled) {
          FirebaseDao.writeError(TypeException.doPurchase, purchase.error);
          purchaseFailed(Exception());
        } else if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
          try {
            PurchaseDto purchaseDto = PurchaseDto.fromPurchaseDetails(purchase);
            FirebaseDao.writePurchase(purchaseDto);
            firebaseProvider.purchase = purchaseDto;
            purchaseSuccesfull();
          } on Exception catch(e) {
            FirebaseDao.writeException(TypeException.doPurchase, e);
            purchaseFailed(e);
          }
        }
      }
    }, onDone: () {
      _subscription.cancel();
    }, onError: (e) {
      FirebaseDao.writeException(TypeException.doPurchase, e);
      purchaseFailed(e);
    });
  }

  buy(String id){
    analyticsService.beginPurchase();
    try{
      InAppPurchase.instance.buyConsumable(
        purchaseParam: PurchaseParam(productDetails : firebaseProvider.productsAvailable.firstWhere((pa) => pa.id == id)), 
        autoConsume: Platform.isIOS || true
      );
    } on Exception catch(e){
      e;
    }
  }

  removePending() async {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition = InAppPurchase.instance.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(PaymentQueueDelegate());
    }
  }
}