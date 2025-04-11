import 'dart:io';
import 'package:fcp/modules/firebase/firebase_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import '../utils/globals.dart';
import '../utils/i18n.dart';
import '../widgets/border_page_widget.dart';
import '../widgets/fcp_app_bar.dart';
import '../widgets/fcp_bottom_sheet_widget.dart';
import '../widgets/outlined_button_ext.dart';

class PurchasePage extends StatefulWidget {
  
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {

  FirebaseProvider firebaseProvider = Provider.of<FirebaseProvider>(navigatorKey.currentContext!, listen: false);

  @override
  initState(){
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      analyticsService.viewPurchase();
      if (!firebaseProvider.isPurchaseAvailable){
        FcpBottomSheetWidget bs = FcpBottomSheetWidget(
          title: Text(I18n.translate((Platform.isAndroid)? 'error.android_puchase_not_available' : 'error.ios_puchase_not_available')),
          acceptText: (I18n.translate('accept')),
          acceptOnPress: () => Navigator.of(navigatorKey.currentContext!).pop(false)
        );
        bs.show();
      }
      if (firebaseProvider.productsAvailable.isEmpty){
        FcpBottomSheetWidget bs = FcpBottomSheetWidget(
          title: Text(I18n.translate('error.purchase_empty')),
          acceptText: (I18n.translate('accept')),
          acceptOnPress: () => Navigator.of(navigatorKey.currentContext!).pop(false)
        );
        bs.show();
      }
      await purchaseService.removePending();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FcpAppBar(
        title: I18n.translate('purchase.title'),
        onPressed: ()=> Navigator.of(navigatorKey.currentContext!).pop(false),
      ),
      body: BorderPageWidget(
          alignment: Alignment.topCenter,
          child: Consumer<FirebaseProvider>(
            builder: (context, firebaseProvider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/images/coffee.png",
                    fit: BoxFit.fitHeight,
                    height: 300,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(children: [
                        Text(
                          I18n.translate('purchase.advantage1'), 
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), 
                          textAlign: TextAlign.center
                        ),
                        const SizedBox(height: 20),
                        Text(I18n.translate('purchase.advantage2')),
                        const SizedBox(height: 20),
                        Text(I18n.translate('purchase.advantage3')),
                        const SizedBox(height: 20),
                        Text(I18n.translate('purchase.advantage4')),
                      ],)
                    )
                  ),
                  for ( var pa in firebaseProvider.productsAvailable )
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: OutlinedButtonExt(
                        title: Text("${pa.price} "),
                        icon: FaIcon((Platform.isAndroid) ? FontAwesomeIcons.googlePay : FontAwesomeIcons.applePay),
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        onPressed: () => purchaseService.buy(pa.id),
                      )
                    ),
                  Visibility(
                    visible: firebaseProvider.purchase != null && firebaseProvider.purchase!.status == PurchaseStatus.pending,
                    child: const CircularProgressIndicator()
                  ),
                  Visibility(
                    visible: firebaseProvider.productsAvailable.isEmpty,
                    child: const CircularProgressIndicator()
                  )
                ]
              );
            }
          )
      )
    );
  }
}
