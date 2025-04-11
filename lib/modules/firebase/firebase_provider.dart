import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../purchase/purchase_dto.dart';
class FirebaseProvider with ChangeNotifier {

  User? _user;
  bool _isPurchaseAvailable = false;
  List<ProductDetails> _productsAvailable = [];
  PurchaseDto? _purchase;

  User? get user => _user;
  bool get isPurchaseAvailable => _isPurchaseAvailable;
  List<ProductDetails> get productsAvailable => _productsAvailable;
  PurchaseDto? get purchase => _purchase;

  set productsAvailable(List<ProductDetails> productsAvailable){
    _productsAvailable = productsAvailable;
    notifyListeners();
  }

  set isPurchaseAvailable(bool isPurchaseAvailable){
    _isPurchaseAvailable= isPurchaseAvailable;
    notifyListeners();
  }

  set user(User? user){
    _user = user;
    notifyListeners();
  }

  set purchase(PurchaseDto? purchase){
    _purchase = purchase;
    notifyListeners();
  }

}