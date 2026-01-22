import 'package:flutter/material.dart';

import '../ui_screen/ui_helper/custom_button.dart';
import '../ui_screen/ui_helper/my_color.dart';

void errorDialogWithPop(context, message, Function() onclick, {barrierDismiss = true, icon = "assets/images/cancel.png"}) {
  AlertDialog dialog = AlertDialog(
    insetPadding: EdgeInsets.zero,
    backgroundColor: MyColor.white,
    title: Row(
      children: [
        Image.asset(
          icon,
          height: 25,
          width: 25,
        ),
        Container(
            margin: const EdgeInsets.only(left: 10),
            child: const Text(
              "Alert",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: MyColor.black,
              ),
            ))
      ],
    ),
    content: Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Text(
        message,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ),
    actions: [
      CustomButton(
        strName: "OK",
        leftPadding: 10,
        rightPadding: 10,
        onClick: () {
          Navigator.pop(context);
          onclick();
        },
      )
    ],
  );
  showDialog(
    barrierDismissible: barrierDismiss,
    context: context,
    builder: (context) {
      return dialog;
    },
  );
}

void richTextMsgDialog(context, text1, richText, text2, Function() onclick, {barrierDismiss = true, icon = "assets/images/cancel.png"}) {
  AlertDialog dialog = AlertDialog(
    insetPadding: EdgeInsets.zero,
    backgroundColor: MyColor.white,
    title: Row(
      children: [
        Image.asset(
          icon,
          height: 25,
          width: 25,
        ),
        Container(
            margin: const EdgeInsets.only(left: 10),
            child: const Text(
              "Alert",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: MyColor.black,
              ),
            ))
      ],
    ),
    content: Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text: text1,
              style: const TextStyle(
                color: MyColor.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: richText,
              style: const TextStyle(
                  color: MyColor.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 18),
            ),
            TextSpan(
              text: text2,
              style: const TextStyle(
                color: MyColor.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      CustomButton(
        strName: "OK",
        leftPadding: 10,
        rightPadding: 10,
        onClick: () {
          Navigator.pop(context);
          onclick();
        },
      )
    ],
  );
  showDialog(
    barrierDismissible: barrierDismiss,
    context: context,
    builder: (context) {
      return dialog;
    },
  );
}

void logoutDialog(title, message, context, Function() onclick) {
  AlertDialog dialog = AlertDialog(
    insetPadding: EdgeInsets.zero,
    backgroundColor: MyColor.white,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/logout.png",
          height: 30,
          width: 30,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ))
      ],
    ),
    content: Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ),
    actions: [
      CustomButton(
        strName: "Yes",
        leftPadding: 10,
        rightPadding: 10,
        backgroundColor: MyColor.projectColor,
        onClick: () {
          onclick();
        },
      ),
      Container(
        margin: const EdgeInsets.only(left: 20),
        child: CustomButton(
          strName: "No",
          backgroundColor: MyColor.red,
          leftPadding: 10,
          rightPadding: 10,
          onClick: () {
            Navigator.pop(context);
          },
        ),
      ),
    ],
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return dialog;
    },
  );
}

void showLoaderDialog(context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return PopScope(
          canPop: false,
          child: Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: 0.35,
                child: Dialog(
                  backgroundColor: MyColor.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  insetPadding: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/images/logo.png",
                          height: 60,
                          width: 130,
                        ),
                        Image.asset(
                          "assets/images/loading.gif",
                          height: 30,
                          width: 130,
                        ),
                      ],
                    ),
                  ),
                ),
              )));
    },
  );
}

void hideLoader(context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context); // Close the dialog
  }
}

void messageDeletedConfirmDialog(context,title,message, onClick1, onClick2) {
  AlertDialog dialog = AlertDialog(
    insetPadding: EdgeInsets.zero,
    backgroundColor: MyColor.white,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/logout.png",
          height: 30,
          width: 30,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ))
      ],
    ),
    content: Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ),
    actions: [
      CustomButton(
        topPadding: 0,
        bottomPadding: 0,
        strName: "Delete for me",
        backgroundColor: MyColor.projectColor,
        onClick: () {
          Navigator.pop(context);
          onClick1();
        },
      ),
      CustomButton(
        topPadding: 0,
        bottomPadding: 0,
        strName: "Delete for everyone",
        backgroundColor: MyColor.projectColor,
        onClick: () {
          Navigator.pop(context);
          onClick2();
        },
      ),
      CustomButton(
        topPadding: 0,
        bottomPadding: 0,
        strName: "Cancel",
        backgroundColor: MyColor.red,
        leftPadding: 10,
        rightPadding: 10,
        onClick: () {
          Navigator.pop(context);
        },
      ),
    ],
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return dialog;
    },
  );
}

void deleteForMeConfirmDialog(context,title,message, onClick1){
  AlertDialog dialog = AlertDialog(
    insetPadding: EdgeInsets.zero,
    backgroundColor: MyColor.white,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/logout.png",
          height: 30,
          width: 30,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ))
      ],
    ),
    content: Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ),
    actions: [
      CustomButton(
        strName: "Delete for me",
        backgroundColor: MyColor.projectColor,
        onClick: () {
          Navigator.pop(context);
          onClick1();
        },
      ),
      CustomButton(
        strName: "Cancel",
        backgroundColor: MyColor.red,
        leftPadding: 10,
        rightPadding: 10,
        onClick: () {
          Navigator.pop(context);
        },
      ),
    ],
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return dialog;
    },
  );
}

void deletedChatRemoveConfirmDialog(context,title,message, onClick1){
  AlertDialog dialog = AlertDialog(
    insetPadding: EdgeInsets.zero,
    backgroundColor: MyColor.white,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/logout.png",
          height: 30,
          width: 30,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ))
      ],
    ),
    content: Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ),
    actions: [
      CustomButton(
        strName: "Yes",
        backgroundColor: MyColor.projectColor,
        onClick: () {
          Navigator.pop(context);
          onClick1();
        },
      ),
      CustomButton(
        strName: "No",
        backgroundColor: MyColor.red,
        leftPadding: 10,
        rightPadding: 10,
        onClick: () {
          Navigator.pop(context);
        },
      ),
    ],
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return dialog;
    },
  );
}
