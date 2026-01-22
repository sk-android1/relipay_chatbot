import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:relipay_chatbot/my_utils/my_dialog.dart';
import 'package:relipay_chatbot/ui_screen/signup_with_mobileNo.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/custom_button.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/custom_text_field.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/error_helper.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_color.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/timer_bottom_sheet.dart';

import 'HomeScreen.dart';

class LoginWithMobileNo extends StatefulWidget{
  const LoginWithMobileNo({super.key});


  @override
  State<StatefulWidget> createState() {
    return _LoginWithMobileNo();
  }

}
class _LoginWithMobileNo extends State<LoginWithMobileNo>{

  TextEditingController etMobileNo = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  var _verificationId = "";

  Future<bool> isMobileNoExist(String mobileNo) async {
    final querySnapshot = await fireStore
        .collection('users')
        .where('mobile_no', isEqualTo: mobileNo)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  void verifyMobileNo(mobileNo) async {

    showLoaderDialog(context);

    await auth.verifyPhoneNumber(
      phoneNumber: '+91$mobileNo',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        hideLoader(context);
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        hideLoader(context);
        _verificationId = verificationId;
        final parentContext = context;
        showModalBottomSheet(
          context: parentContext,
          isScrollControlled: false,
          isDismissible: false,
          enableDrag: false,
          backgroundColor: MyColor.projectColor,
          builder: (BuildContext sheetContext) {
            return WillPopScope(
                child: TimerBottomSheet(
                  onVerify: (pinValue) {
                    verifyOtp(pinValue);
                  },
                  resendOtpApiCalled: () {
                    Navigator.pop(sheetContext);
                    verifyMobileNo(mobileNo);
                  },
                ),
                onWillPop: () async {
                  return false;
                });
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {

      },
    );
  }

  void verifyOtp(otp) async {
    try{
      showLoaderDialog(context);
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      UserCredential userCred =
      await auth.signInWithCredential(credential);

      var currentUid = userCred.user!.uid;

      hideLoader(context);

      Navigator.of(context, rootNavigator: true)
          .pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    }on FirebaseAuthException catch (e) {
      hideLoader(context);
      if (e.code == 'invalid-verification-code') {
        errorDialogWithPop(context, "Invalid OTP. Please try again", () => null);
      } else {
        errorDialogWithPop(context, "OTP verification failed", () => null);
      }
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
                 alignment: Alignment.topLeft,
                 margin: const EdgeInsets.only(left: 20),
                 child: const Text(
                   "Hey",
                   style: TextStyle(
                       fontSize: 15,
                       color: MyColor.black,
                       fontWeight: FontWeight.w500),
                 )),
             Container(
                 alignment: Alignment.topLeft,
                 margin: const EdgeInsets.only(left: 20),
                 child: const Text(
                   "Welcome Back",
                   style: TextStyle(
                       fontSize: 18,
                       color: MyColor.black,
                       fontWeight: FontWeight.w500),
                 )),
             Container(
                 alignment: Alignment.topLeft,
                 margin: const EdgeInsets.only(left: 20, top: 30),
                 child: const Text(
                   "Mobile Number",
                   style: TextStyle(
                       fontSize: 15,
                       color: MyColor.black,
                       fontWeight: FontWeight.w500),
                 )),
             CustomTextField(
               strHint: 'Enter mobile number',
               controller: etMobileNo,
               inputType: TextInputType.phone,
             ),

             Container(
                 alignment: Alignment.center,
                 margin: const EdgeInsets.only(top: 50),
                 height: 50,
                 width: double.infinity,
                 child:CustomButton(strName: "Next",onClick: () async {

                   if(await isMobileNoExist(etMobileNo.text)) {
                     verifyMobileNo(etMobileNo.text);
                   }
                   else {
                     Navigator.push(context, MaterialPageRoute(builder: (_)=>SignUpWithMobileNoScreen(etMobileNo.text)));
                   }

                 },)

             ),

           ],
         ),
       ),
     ),
   );
  }

}