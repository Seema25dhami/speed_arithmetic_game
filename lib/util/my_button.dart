import 'package:flutter/material.dart';

import '../const.dart';

class MyButton extends StatelessWidget {
  final String child;
  final VoidCallback onTap; //accept the funtion and pass thorugh the button
  var buttonColor = Color.fromARGB(255, 37, 109, 119);

  MyButton({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (child == 'CLEAR ALL') {
      buttonColor = Colors.green;
    } else if (child == 'DELETE') {
      buttonColor = Colors.red;
    } else if (child == '=') {
      buttonColor = Color.fromARGB(255, 13, 71, 78);
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
              style: whiteTextStyle,
            ),
          ),
        ),
      ),
    );
  }
}
