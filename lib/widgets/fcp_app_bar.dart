import 'package:flutter/material.dart';
import '../utils/globals.dart';

class FcpAppBar extends AppBar {
  FcpAppBar({
    super.key,
    bool showCircularProgress = false, 
    String? title,
    VoidCallback? onPressed})
  : super(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.blue),
      onPressed: ()=> (onPressed == null) ? Navigator.of(navigatorKey.currentContext!).pop() : onPressed()
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    title: Text(title ?? "", style: TextStyle(color: (preferencesService.enabledDarkMode == true) ? Colors.white : Colors.black)),
    actions: <Widget>[
      (showCircularProgress)
      ? FittedBox(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            child: const CircularProgressIndicator(),
          ),
        )
      : Container()
    ]
  );
}