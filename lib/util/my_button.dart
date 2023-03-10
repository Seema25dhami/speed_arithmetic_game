import 'dart:ui';

import 'package:flutter/material.dart';
import '../const.dart';

class MyButton extends StatelessWidget {
  final String child;
  final VoidCallback onTap; //accept the funtion and pass thorugh the button
  var buttonColor = Color.fromARGB(255, 37, 109, 119);
  var textStyle = whiteTextStyle;

  MyButton({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (child == 'BACKSPACE') {
      buttonColor = Color.fromARGB(255, 233, 213, 41);
      textStyle = actionButtonTextStyle;
    } else if (child == 'CLEAR ALL') {
      buttonColor = Colors.red;
      textStyle = actionButtonTextStyle;
    } else if (child == 'SUBMIT') {
      buttonColor = Colors.green;
      textStyle = actionButtonTextStyle;
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              child,
              style: textStyle,
            ),
          ),
        ),
      ),
    );
  }
}
