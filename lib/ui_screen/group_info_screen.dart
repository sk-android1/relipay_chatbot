import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:relipay_chatbot/my_utils/my_dialog.dart';
import 'package:relipay_chatbot/ui_screen/add_member_in_group.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/error_helper.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_color.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_widget.dart';

class GroupInfoScreen extends StatefulWidget {
  String groupId;
  String groupName;
  List<Map<String, dynamic>> memberList;

  GroupInfoScreen(this.groupId, this.groupName, this.memberList, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _GroupInfoScreenState();
  }
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  var uid = "";

  Future<bool> checkIsAdmin() async {
    final doc = await fireStore.collection('groups').doc(widget.groupId).get();

    if (!doc.exists) return false;

    List members = doc['member'];

    // for(var admin in members){
    //   admin['uid'] == uid;
    // }

    bool isAdmin = false;

    for (var adminUser in members) {
      if (adminUser['uid'] == auth.currentUser!.uid) {
        isAdmin = adminUser['isAdmin'] == true;
        break; // stop loop once found
      }
    }

    return isAdmin;
  }

  Future<void> exitGroup() async {
    bool isAdmin = await checkIsAdmin();

    if (!isAdmin) {
      widget.memberList.removeWhere((m) => m['uid'] == uid);

      await fireStore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();
      await fireStore.collection('groups').doc(widget.groupId).update({
        'member': widget.memberList,
      });
      setState(() {});
    } else {
      ErrorHelper.showSnackBar("you are admin", context);
    }
  }

  Future<void> removeMember(index) async {
    bool isAdmin = await checkIsAdmin();

    if (isAdmin) {
      showLoaderDialog(context);

      var userId = widget.memberList[index]['uid'];

      await fireStore
          .collection('users')
          .doc(userId)
          .collection('groups')
          .doc(widget.groupId)
          .delete();
      await memberUpdateMessage(
          "${auth.currentUser!.displayName} remove ${widget.memberList[index]['name']} from this group");
      widget.memberList.removeAt(index);
      await fireStore.collection('groups').doc(widget.groupId).update({
        'member': widget.memberList,
      });

      hideLoader(context);
      setState(() {});
    } else {
      ErrorHelper.showSnackBar("you are not admin", context);
    }
  }

  Future<void> memberUpdateMessage(updateMessage) async {
    Map<String, dynamic> messages = {
      'senderId': auth.currentUser?.uid,
      'senderName': auth.currentUser?.displayName,
      'message': "",
      'message_type': "text",
      'time': FieldValue.serverTimestamp(),
      'memberUpdateMessage': updateMessage,
    };

    await fireStore
        .collection('group_chatroom')
        .doc(widget.groupId)
        .collection('group_chats')
        .add(messages);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.lightGrey,
      body: Container(
        margin: const EdgeInsets.only(top: 45),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10),
              child: floatingActionBtn(Icons.arrow_back, size: 35.0, () {
                Navigator.pop(context);
              }),
            ),
            Column(
              children: [
                if (widget.memberList.length < 7) ...[
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/images/groupchat.png",
                        height: 110,
                        width: 110,
                      )),
                ],
                Container(
                    margin: const EdgeInsets.only(top: 0),
                    child: Text(
                      widget.groupName,
                      style: const TextStyle(
                          color: MyColor.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 0),
                    child: Text(
                      "Group Members : ${widget.memberList.length.toString()}",
                      style: const TextStyle(
                          color: MyColor.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    )),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: const Divider(
                      height: 2,
                      color: MyColor.grey,
                    )),
                Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(left: 15),
                    child: Text(
                      "${widget.memberList.length.toString()} members",
                      style: const TextStyle(
                          color: MyColor.projectColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    )),
                InkWell(
                  onTap: ()async{
                    if (await checkIsAdmin()) {
                    Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                    builder: (_) =>
                    AddMemberInGroup(
                    widget.groupId,
                    widget.groupName,
                    widget.memberList)
                    ));
                    } else {
                    ErrorHelper.showSnackBar(
                    "You are not Admin", context);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    child: Row(
                      children: [
                        floatingActionBtn(Icons.group, size: 46.0, () async {
                          // if (await checkIsAdmin()) {
                          //   Navigator.pushReplacement(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (_) =>
                          //               AddMemberInGroup(
                          //               widget.groupId,
                          //               widget.groupName,
                          //               widget.memberList)
                          //       ));
                          // } else {
                          //   ErrorHelper.showSnackBar(
                          //       "You are not Admin", context);
                          // }
                        }
                        ),
                        Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: const Text(
                              "Add Members",
                              style: TextStyle(
                                  color: MyColor.projectColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ))
                      ],
                    ),
                  ),
                ),
                allList(),
                InkWell(
                  onTap: () {
                    exitGroup();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 15, bottom: 50),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.exit_to_app,
                          color: MyColor.red,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 15),
                          child: const Text(
                            "Exit from group",
                            style: TextStyle(
                                color: MyColor.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget allList() {
    return Expanded(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: widget.memberList.length,
            itemBuilder: (context, index) {
              var uid = widget.memberList[index]['uid'].toString();
              var name = widget.memberList[index]['name'].toString();
              var email = widget.memberList[index]['email'].toString();
              bool isAdmin = widget.memberList[index]['isAdmin'];

              if (auth.currentUser!.uid == uid) {
                name = "You";
              }

              return listItem(name, email, isAdmin, () async {
                if (await checkIsAdmin()) {
                  if (!isAdmin) {
                    richTextMsgDialog(
                        context,
                        'Are you sure you want to remove ',
                        name,
                        ' from this group', () async {
                      await removeMember(index);
                    });
                  }
                } else {
                  ErrorHelper.showSnackBar("You are not Admin", context);
                }
              });
            }),
      ),
    );
  }

  Widget listItem(name, email, isAdmin, onclick) {
    return GestureDetector(
      onLongPress: () {
        onclick();
      },
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 0),
          width: double.infinity,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  name != "You" ? MyColor.projectColor : MyColor.darkGrey,
              foregroundColor: MyColor.white,
              radius: 22,
              child: const Icon(Icons.person_outline_outlined),
            ),
            title: Text(
              name,
              style: const TextStyle(
                  color: MyColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            subtitle: Text(email),
            trailing: isAdmin
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                    decoration: BoxDecoration(
                        color: MyColor.lightGreen2,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text(
                      "Admin",
                      style: TextStyle(
                          color: MyColor.darkGreen,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ))
                : const Text(""),
          )),
    );
  }
}
