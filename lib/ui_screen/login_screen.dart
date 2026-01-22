import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:relipay_chatbot/my_utils/my_dialog.dart';
import 'package:relipay_chatbot/ui_screen/HomeScreen.dart';
import 'package:relipay_chatbot/ui_screen/signup_screen.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/custom_button.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/custom_text_field.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/error_helper.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_color.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/password_container_textfield.dart';

class LogInScreen extends StatefulWidget{
  const LogInScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LogInScreenState();
  }

}
class _LogInScreenState extends State<LogInScreen> {

  var etEmail = TextEditingController();
  var etPassword = TextEditingController();

  Future<User?> login(email, password) async {

    FirebaseAuth auth = FirebaseAuth.instance;

    showLoaderDialog(context);

    try {


      User? user = (await auth.signInWithEmailAndPassword(email: email, password: password)).user;

      if(user != null) {
        hideLoader(context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const HomeScreen()));

        return user;
      }
      else {
        hideLoader(context);
        ErrorHelper.showSnackBar("Login Failed", context);
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
                alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(left: 20),
                  child: Text(
                    "Hey",
                    style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500),
                  )),
              Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(left: 20),
                  child: Text(
                    "Welcome Back",
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500),
                  )),
              Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(left: 20, top: 30),
                  child: Text(
                    "Email",
                    style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500),
                  )),
              CustomTextField(
                strHint: 'Please enter email',
                controller: etEmail,
              ),
              Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
                  child: Text(
                    "Password",
                    style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500),
                  )),
              PasswordContainerTextField(
                etPassword,
                'Enter Password',
              ),
              InkWell(
                onTap: () {

                },
                child: Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(right: 20, top: 5),
                    child: const Text(
                      "Forget Password?",
                      style: TextStyle(
                          fontSize: 13,
                          color: MyColor.blue,
                          fontWeight: FontWeight.w600),
                    )),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 50),
                height: 50,
                width: double.infinity,
                child:CustomButton(strName: "Login",onClick: () async {
                 await login(etEmail.text, etPassword.text);
                },)

              ),

              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_)=> const SignUpScreen()));
                },

                child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 50),
                    height: 50,
                    width: double.infinity,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account ",style: TextStyle(color: MyColor.black, fontSize: 16, fontWeight: FontWeight.w500),),
                        Text("Signup", style: TextStyle(color: MyColor.projectColor, fontSize: 20, fontWeight: FontWeight.w800),)
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