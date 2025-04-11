import 'package:flutter/material.dart';
import '../utils/globals.dart';
import 'outlined_button_ext.dart';

class FcpBottomSheetWidget {
  Widget title;
  Widget? subtitle;
  String acceptText;
  String? cancelText;
  VoidCallback acceptOnPress;
  VoidCallback? cancelOnPress;

  FcpBottomSheetWidget({required this.title, this.subtitle, required this.acceptText, this.cancelText, required this.acceptOnPress, this.cancelOnPress});

  Future show() {
    return showModalBottomSheet(
      context: navigatorKey.currentContext!,
      isDismissible: false,
      builder: (BuildContext bc) {
        return FractionallySizedBox(
          alignment: Alignment.topCenter,
          heightFactor: 0.5,
          child: SizedBox(
            width: double.infinity,
            child:Container(
              margin: const EdgeInsets.only(left: 32, right: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: [
                  title,
                  subtitle ??= Container(),
                  OutlinedButtonExt(
                    title: Text(acceptText), 
                    onPressed: acceptOnPress,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  ),
                  cancelText == null ? Container():
                    OutlinedButtonExt(
                      title: Text(cancelText!), 
                      onPressed: cancelOnPress,  
                    )
                ]
              )
            )
          )
        );
      }
    );
  }
}      