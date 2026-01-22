import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:relipay_chatbot/ui_screen/login_screen.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/custom_button.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/custom_text_field.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/error_helper.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_color.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/password_container_textfield.dart';

import '../my_utils/my_dialog.dart';

class SignUpScreen extends StatefulWidget{
  const SignUpScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SignUpScreenState();
  }

}
class _SignUpScreenState extends State<SignUpScreen> {

  var etName = TextEditingController();
  var etEmail = TextEditingController();
  var etPassword = TextEditingController();

  Future<User?> createAccount(name, email, password) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore fireStore = FirebaseFirestore.instance;

    showLoaderDialog(context);

    try{
      User? user = (await auth.createUserWithEmailAndPassword(email: email, password: password)).user;

      if(user != null) {

        user.updateProfile(displayName: name);

        await fireStore.collection('users').doc(auth.currentUser?.uid).set({
          'name':name,
          'email':email,
          'password':password,
          'status' : "unavailable",
          'time':FieldValue.serverTimestamp(),
          'last_seen':FieldValue.serverTimestamp(),
          'uid': auth.currentUser!.uid,
          'type': "user"
        });
        hideLoader(context);
        ErrorHelper.showSnackBar("account created successfully", context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const LogInScreen()));
        return user;
      }
      else {
        hideLoader(context);
        ErrorHelper.showSnackBar("account creation failed", context);
        return user;
      }

    } catch(e) {
      hideLoader(context);
      ErrorHelper.showSnackBar("$e", context);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body: SingleChildScrollView(
       scrollDirection: Axis.vertical,
       child: Container(
         height: MediaQuery.of(context).size.height,
         margin: const EdgeInsets.only(top: 0),
         color: MyColor.lightGrey,
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             Container(
                 alignment: Alignment.center,
                 height: 150,
                 width: 150,
                 margin: const EdgeInsets.only(top: 50),
                 child: Image.asset(
                   "assets/images/groupchat.png",
                 )),
             Container(

                 margin: const EdgeInsets.only(left: 20,top: 30),
                 child: Text(
                   "Enter details for signup",
                   style: TextStyle(
                       fontSize: 20,
                       color: Theme.of(context).colorScheme.onSurface,
                       fontWeight: FontWeight.w600),
                 )),

             Container(
                 alignment: Alignment.topLeft,
                 margin: const EdgeInsets.only(left: 20, top: 30),
                 child: Text(
                   "Name",
                   style: TextStyle(
                       fontSize: 15,
                       color: Theme.of(context).colorScheme.onSurface,
                       fontWeight: FontWeight.w500),
                 )),
             CustomTextField(
               strHint: 'Enter name',
               controller: etName,
               marginTop: 5,
             ),
             Container(
                 alignment: Alignment.topLeft,
                 margin: const EdgeInsets.only(left: 20, top: 20, bottom: 0),
                 child: Text(
                   "Email",
                   style: TextStyle(
                       fontSize: 15,
                       color: Theme.of(context).colorScheme.onSurface,
                       fontWeight: FontWeight.w500),
                 )),
             CustomTextField(
               strHint: 'Enter email',
               controller: etEmail,
               marginTop: 5,
             ),
             Container(
                 alignment: Alignment.topLeft,
                 margin: const EdgeInsets.only(left: 20, top: 20, bottom: 0),
                 child: Text(
                   "Password",
                   style: TextStyle(
                       fontSize: 15,
                       color: Theme.of(context).colorScheme.onSurface,
                       fontWeight: FontWeight.w500),
                 )),
             PasswordContainerTextField(
               etPassword,
                'Enter password',
             ),

             Container(
                 alignment: Alignment.center,
                 margin: const EdgeInsets.only(top: 40),
                 height: 50,
                 width: double.infinity,
                 child:CustomButton(strName: "Signup",onClick: ()async{
                   await createAccount(etName.text, etEmail.text, etPassword.text);
                 },)

             ),

             InkWell(
               onTap: (){
                 Navigator.pop(context);
               },
               child: Container(
                   alignment: Alignment.center,
                   margin: const EdgeInsets.only(top: 30),
                   height: 50,
                   width: double.infinity,
                   child: const Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text("Already have an account ",style: TextStyle(color: MyColor.black, fontSize: 16, fontWeight: FontWeight.w500),),

                       Text("Login", style: TextStyle(color: MyColor.projectColor, fontSize: 20, fontWeight: FontWeight.w800),)
                     ],
                   )),
             )

           ],
         ),
       ),
     ),
   );
  }

}