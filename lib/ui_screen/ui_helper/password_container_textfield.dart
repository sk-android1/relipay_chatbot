import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'my_color.dart';


class PasswordContainerTextField extends StatefulWidget {

  var passCtrl = TextEditingController();
  var hint = "Password";

   PasswordContainerTextField(this.passCtrl,this.hint,{super.key});

  @override
  State<PasswordContainerTextField> createState() => _PasswordContainerTextFieldState();

}

class _PasswordContainerTextFieldState extends State<PasswordContainerTextField> {

  bool passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      padding: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
         color: MyColor.white,
          borderRadius: BorderRadius.circular(5),
        //  border: Border.all(color: Theme.of(context).colorScheme.onSurface,)
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
      child: TextField(
        style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface,),
        controller: widget.passCtrl,
        keyboardType: TextInputType.visiblePassword,
        cursorColor: Theme.of(context).colorScheme.onSurface,
        obscureText: passwordVisible,
        decoration: InputDecoration(
       //   contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          border: InputBorder.none,
            hintText: widget.hint,
            hintStyle: TextStyle(color: MyColor.darkGrey,fontWeight: FontWeight.w400),
            suffixIconColor: MyColor.darkGrey,
            suffixIcon: IconButton(
              icon: Icon(passwordVisible
                  ? Icons.visibility
                  : Icons.visibility_off),
              onPressed: () {
                setState(
                      () {
                    passwordVisible = !passwordVisible;
                  },
                );
              },
            ),

           ),
      ),
    );
  }
}
