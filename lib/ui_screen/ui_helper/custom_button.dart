import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'my_color.dart';


class CustomButton extends StatelessWidget{
  final String strName;
  final Icon? icon;
  final double leftPadding;
  final double rightPadding;
  final double topPadding;
  final double bottomPadding;
  final double fontSize;
  final Color backgroundColor;
  final VoidCallback? onClick;
  final double radius;
  const CustomButton({super.key, required this.strName, this.icon,  this.leftPadding = 5,  this.rightPadding = 5, this.topPadding = 10,
    this.bottomPadding = 10,  this.backgroundColor = MyColor.projectColor, this.fontSize = 16,this.radius = 10, this.onClick});

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius))
        ),
        onPressed: (){
          onClick!();
        },
        child:  Padding(
          padding:  EdgeInsets.only(left: leftPadding, right: rightPadding, top: topPadding, bottom: bottomPadding),
          child: icon != null ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text( strName, style:  TextStyle(fontSize: fontSize,  fontWeight: FontWeight.w400, color: Colors.white)),
              icon!
            ],
          ) : Text( strName, style:  TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white)),
        )
    );
  }

}