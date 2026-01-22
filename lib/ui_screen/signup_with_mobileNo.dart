import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/custom_button.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/custom_text_field.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/error_helper.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_color.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/timer_bottom_sheet.dart';

import '../my_utils/my_dialog.dart';
import 'HomeScreen.dart';

class SignUpWithMobileNoScreen extends StatefulWidget {

 final String mobileNo;

  const SignUpWithMobileNoScreen(this.mobileNo,{super.key});

  @override
  State<StatefulWidget> createState() {
    return _SignUpWithMobileNoScreenState();
  }

}
class _SignUpWithMobileNoScreenState extends State<SignUpWithMobileNoScreen> {

  var etMobileNo = TextEditingController();
  var etName = TextEditingController();
  var etEmail = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  var _verificationId = "";

  void verifyMobileNo(mobileNo)async{
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

                  },
                ),
                onWillPop: () async {
                  return false;
                });
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        hideLoader(context);
      },
    );
  }

  void verifyOtp(otp)async {
    try{
      showLoaderDialog(context);
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      UserCredential userCred =
      await auth.signInWithCredential(credential);

      User? user = userCred.user;
      
      if(user != null){
        var currentUid = user.uid;
       await user.updateDisplayName(etName.text);
        await user.reload();

        await fireStore.collection('users').doc(currentUid).set({
          'mobile_no':etMobileNo.text,
          'name':etName.text,
          'email':etEmail.text,
          'status' : "unavailable",
          'time':FieldValue.serverTimestamp(),
          'last_seen':FieldValue.serverTimestamp(),
          'uid': currentUid,
          'type': "user"
        });

        hideLoader(context);
        Navigator.of(context, rootNavigator: true)
            .pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      }
      else {
        hideLoader(context);
        errorDialogWithPop(context, "account creation failed", () => null);
      }
      

    }on FirebaseAuthException catch (e) {
      hideLoader(context);
      if (e.code == 'invalid-verification-code') {
        // Wrong OTP
        errorDialogWithPop(context, "Invalid OTP. Please try again", () => null);


      } else {
        errorDialogWithPop(context, "OTP verification failed", () => null);

      }
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    etMobileNo.text = widget.mobileNo;
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
              InkWell(
                onTap: (){

                },
                child: Container(
                    alignment: Alignment.center,
                    height: 150,
                    width: 150,
                    margin: const EdgeInsets.only(top: 50),
                    child: Image.asset(
                      "assets/images/groupchat.png",
                    )),
              ),
              Container(
                  margin: const EdgeInsets.only(left: 20,top: 30),
                  child: const Text(
                    "Enter details for next step",
                    style: TextStyle(
                        fontSize: 20,
                        color: MyColor.black,
                        fontWeight: FontWeight.w600),
                  )),

              Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(left: 20, top: 30),
                  child: const Text(
                    "MobileNo",
                    style: TextStyle(
                        fontSize: 15,
                        color: MyColor.black,
                        fontWeight: FontWeight.w500),
                  )),
              CustomTextField(
                strHint: 'Enter mobile no',
                controller: etMobileNo,
                marginTop: 5,
                isEnable: false,
              ),

              Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(left: 20, top: 30),
                  child: const Text(
                    "Name",
                    style: TextStyle(
                        fontSize: 15,
                        color: MyColor.black,
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
                  child: const Text(
                    "Email",
                    style: TextStyle(
                        fontSize: 15,
                        color: MyColor.black,
                        fontWeight: FontWeight.w500),
                  )),
              CustomTextField(
                strHint: 'Enter email',
                controller: etEmail,
                inputType: TextInputType.emailAddress,
                marginTop: 5,
              ),

              Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 40),
                  height: 50,
                  width: double.infinity,
                  child:CustomButton(strName: "Next",onClick: ()async{
                     verifyMobileNo(etMobileNo.text);
                  },)

              ),

            ],
          ),
        ),
      ),
    );
  }

}