import 'package:fcp/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'outlined_button_ext.dart';

class DialogInputWidget{

  Key? key;
  String? hintText;
  String acceptText;
  String cancelText;
  Function(String) acceptOnPress;
  VoidCallback cancelOnPress;

  DialogInputWidget({
    this.key,
    required this.acceptText, 
    required this.cancelText, 
    required this.acceptOnPress, 
    required this.cancelOnPress, 
    this.hintText
  });

  show() async {
    final TextEditingController controller = TextEditingController();
    await showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  key: (key == null) ? UniqueKey() : key,
                  controller: controller,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  decoration: InputDecoration(
                    hintText: (hintText == null) ? '' : hintText,
                  ),
                  onEditingComplete: () => acceptOnPress(controller.text)
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    OutlinedButtonExt(
                      title: Text(cancelText), 
                      onPressed: ()=> Navigator.of(context).pop(false),  
                    ),
                    const SizedBox(width: 8.0),
                    OutlinedButtonExt(
                      title: Text(acceptText), 
                      onPressed: (){
                        if (controller.text != "") acceptOnPress(controller.text);
                        Navigator.of(context).pop(false);
                      },  
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
   }
}