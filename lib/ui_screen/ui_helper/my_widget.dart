import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'my_color.dart';

Widget floatingActionBtn(icon, onclick, {size = 60.0,backgroundColor = MyColor.projectColor}){
  return Container(
    height: size,
    width: size,

    child: FloatingActionButton(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // change radius here
      ),
      backgroundColor: backgroundColor,
      foregroundColor: MyColor.white,
      onPressed: () {
       onclick();
      },
      child:  Icon(icon),

    ),
  );
}