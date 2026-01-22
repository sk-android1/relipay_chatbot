import 'dart:async';

import 'package:flutter/material.dart';

import 'package:pinput/pinput.dart';

import 'custom_button.dart';
import 'my_color.dart';

class TimerBottomSheet extends StatefulWidget {
  //final VoidCallback onVerify;
  final ValueChanged<String> onVerify;
  final VoidCallback resendOtpApiCalled;

  TimerBottomSheet(
      {super.key, required this.onVerify, required this.resendOtpApiCalled});

  @override
  State<StatefulWidget> createState() {
    return _TimerBottomSheetState();
  }
}

class _TimerBottomSheetState extends State<TimerBottomSheet> {
  final TextEditingController otpCtrl = TextEditingController();
  final TextEditingController userIdCtrl = TextEditingController();
  var pinViewValue = "";
  bool isTimerShow = true;
  int seconds = 60;
  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds == 0) {
        timer.cancel();
        setState(() {
          isTimerShow = false;
        });
      } else {
        setState(() {
          seconds--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5),
              decoration: const BoxDecoration(
                color: MyColor.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 23,
                          width: 23,
                          margin: const EdgeInsets.all(12),
                          child: Image.asset(
                            "assets/images/cancel.png",
                          ),
                        ),
                      )),
                  // SizedBox(
                  //   height: 25,
                  // ),
                  const Text(
                    "Please Enter OTP",
                    style: TextStyle(
                        color: MyColor.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ),
                  Container(
                      margin: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 20),
                      child: const Text(
                        "Your one time password (OTP) has been sent via SMS to your registered mobile number",
                        style: TextStyle(
                            color: MyColor.darkGrey,
                            fontWeight: FontWeight.w500,
                            fontSize: 13),
                        textAlign: TextAlign.center,
                      )),
                  //  CustomTextField(strHint: "Enter OTP", controller: null,),
                  pinView(otpCtrl),

                  if (isTimerShow) ...[
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("This OTP will expired in "),
                          Text(
                            "$seconds seconds",
                            style: const TextStyle(
                                color: MyColor.projectColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                          )
                        ],
                      ),
                    ),
                  ],

                  Container(
                      margin: const EdgeInsets.only(
                        top: 50,
                      ),
                      child: CustomButton(
                          strName: "Verify & Proceed",
                          onClick: () {
                            widget.onVerify(pinViewValue);
                          })),

                  if (!isTimerShow) ...[
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Didn't receive OTP Code? "),
                          InkWell(
                              onTap: () {
                                //   Navigator.pop(context);
                                widget.resendOtpApiCalled();
                              },
                              child: const Text(
                                " Resend OTP",
                                style: TextStyle(
                                    color: MyColor.projectColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15),
                              ))
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(
                    height: 70,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget pinView(controller) {
    return Center(
      child: Pinput(
        controller: controller,
        obscureText: true,
        obscuringWidget: Text(
          "*",
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        autofocus: true,
        length: 6,
        defaultPinTheme: PinTheme(
            width: 47,
            height: 47,
            textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20),
            decoration: BoxDecoration(
                border: Border.all(color: MyColor.grey, width: 1),
                borderRadius: BorderRadius.circular(7))),
        focusedPinTheme: PinTheme(
            width: 47,
            height: 47,
            textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20),
            decoration: BoxDecoration(
                border: Border.all(color: MyColor.darkGrey, width: 1.5),
                borderRadius: BorderRadius.circular(7))),
        onChanged: (value) {},
        onCompleted: (value) {
          pinViewValue = value;
        },
        onSubmitted: (value) {},
      ),
    );
  }
}
