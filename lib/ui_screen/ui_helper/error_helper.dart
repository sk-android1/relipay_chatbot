import 'package:flutter/material.dart';

import 'my_color.dart';

class ErrorHelper{

 static void showSnackBar(String message, context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: MyColor.projectColor, fontSize: 16),),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.fixed,
        backgroundColor: MyColor.white,
      ),
    );
  }

}