// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

enum ButtonAlignment{
  horizontal,
  vertical
}

enum IconAlignment{
  left,
  right
}

//button with elements in a row
class OutlinedButtonExt extends StatelessWidget {

  Widget title;
  Widget? icon;
  VoidCallback? onPressed;
  double? maxWith;
  Color? backgroundColor;
  Color? textColor;
  EdgeInsetsGeometry? padding;
  ButtonAlignment? alignment;
  IconAlignment? iconAlignment;
  OutlinedButtonExt(
    {super.key, 
    required this.title, 
    this.icon, 
    required this.onPressed, 
    this.maxWith, 
    this.backgroundColor,
    this.textColor, 
    this.alignment = ButtonAlignment.horizontal, 
    this.iconAlignment = IconAlignment.left ,
    this.padding = const EdgeInsets.all(0.0)
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(width: 1.0, color: Colors.blue),
        backgroundColor: (backgroundColor == null) ? Colors.white : backgroundColor!,
        foregroundColor: (textColor == null) ? Colors.black : textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: const BorderSide(color: Colors.black)
        )
      ),
      child: Padding(
        padding: padding!,
        child: (alignment == ButtonAlignment.horizontal)  ? 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (icon == null) ? 
                        [title] : 
                        (iconAlignment == IconAlignment.left) ?
                          [icon!, const SizedBox(width: 5), title] :
                          [title, const SizedBox(width: 5), icon!]
          ):
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (icon == null) ? [title] : [icon!, const SizedBox(height: 5), title],
          )
      )
    );
  }
}
          
          