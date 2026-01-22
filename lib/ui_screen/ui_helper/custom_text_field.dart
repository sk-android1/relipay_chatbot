
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'my_color.dart';



class CustomTextField extends StatelessWidget {
  final String strHint;
  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final double marginTop ;
  final double marginBottom ;
  final double marginLeft ;
  final double marginRight ;
  final TextInputType inputType;
  final bool isObSecure;      //  password type input
  final TextCapitalization textCapitalization;
  final TextEditingController? controller;
  final int? textLength;
  final onChanged;
  final isEnable;
  final onSubmit;
  final errorText;
  final backgroundColor;
  final borderColor;
  final double leftPadding;
  final double radius;


  const CustomTextField({super.key, required this.strHint,this.errorText,this.backgroundColor = MyColor.white, this.leftPadding = 15,this.prefixIcon, this.suffixIcon,this.marginTop = 10,this.borderColor = MyColor.white,this.marginBottom = 7,this.marginLeft = 20,this.marginRight = 20,
    this.inputType = TextInputType.text,this.isObSecure = false,this.textCapitalization = TextCapitalization.none,this.controller, this.textLength, this.isEnable, this.onChanged, this.onSubmit,this.radius = 5.0});

  @override
  Widget build(BuildContext context) {
    return  Container(

      margin: EdgeInsets.only(left: marginLeft, right: marginRight, top: marginTop, bottom: marginBottom),
      padding: EdgeInsets.only(left: leftPadding),
      decoration: BoxDecoration(
         color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      //   border: Border.all(color: Theme.of(context).colorScheme.onSurface,)
         // border: Border.all(color: MyColor.projectColor2),
        // boxShadow: [
        //   BoxShadow(
        //     color: MyColor.grey,
        //     blurRadius: 2,
        //     spreadRadius: 1,
        //     offset: Offset(1, 2)
        //   )
        // ]
      ),
     child: Container(

       child: TextField(
         style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface,),
         onChanged: onChanged,
          onSubmitted: onSubmit,
          controller: controller,
          enabled: isEnable,
          keyboardType: inputType,
          obscureText: isObSecure,
          obscuringCharacter: "*",
          cursorColor: Theme.of(context).colorScheme.onSurface,

          textCapitalization: textCapitalization,
          inputFormatters: [
            LengthLimitingTextInputFormatter(textLength)
          ],

          decoration: InputDecoration(
            hintStyle: TextStyle(color: MyColor.darkGrey, fontWeight: FontWeight.w400),
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            border: InputBorder.none,
              hintText: strHint,
              errorText: errorText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
            suffixIconColor: Theme.of(context).colorScheme.onSurface,

          ),
        ),
     ),
    );
  }



}
