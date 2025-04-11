import 'package:in_app_purchase/in_app_purchase.dart';

extension ParsePSToString on PurchaseStatus {
  String value() {
    return toString().split('.').last;
  }
}

class PurchaseDto{

  String purchaseID;
  String transactionDate;
  PurchaseStatus status;
  String purchaseStore;
  IAPError? error;

  PurchaseDto({
    required this.purchaseID,
    required this.transactionDate,
    required this.status,
    required this.purchaseStore,
    this.error
  });

  factory PurchaseDto.fromPurchaseDetails(PurchaseDetails pd){
    return PurchaseDto(
      purchaseID: pd.purchaseID!,
      transactionDate: pd.transactionDate!,
      status:  pd.status,
      purchaseStore: pd.runtimeType.toString(),
      error: pd.error
    );
  }

  factory PurchaseDto.fromJson(json) {
    PurchaseDto fpdb = PurchaseDto(
      purchaseID: json["purchaseID"],
      transactionDate: json["transactionDate"],
      purchaseStore: json["purchaseStore"],
      status: PurchaseStatus.values.firstWhere((e) => e.toString() == 'PurchaseStatus.${json["status"]}')
    );
    if (json['errorSource'] != null && 
        json['errorCode'] != null &&
        json['errorMessage'] != null &&
        json['errorDetails'] != null){
          fpdb.error = IAPError(
            source: json['errorSource'] ?? '',
            code: json['errorCode'] ?? '',
            message: json['errorMessage'] ?? '',
            details: json['errorDetails'] ?? '',
          );
        }
    return fpdb;
  }

  Map<String, dynamic> toJson(){
    Map<String, dynamic> result = {
      'purchaseID': purchaseID,
      'transactionDate': transactionDate,
      'purchaseStore': purchaseStore,
      'status': status.value()   
    };
    if (error != null){
      result["errorSource"] = error!.source;
      result["errorCode"] = error!.code;
      result["errorMessage"] = error!.message;
      result["errorDetails"] = error!.details;
    }
    return result;
  }
}