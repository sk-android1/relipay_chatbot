import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:relipay_chatbot/my_utils/my_dialog.dart';
import 'package:relipay_chatbot/ui_screen/group_chat_screen.dart';
import 'package:relipay_chatbot/ui_screen/group_info_screen.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/custom_text_field.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/error_helper.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_color.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_widget.dart';

class AddMemberInGroup extends StatefulWidget {
  List<Map<String, dynamic>> memberList;
  String groupId;
  String groupName;

  AddMemberInGroup(this.groupId, this.groupName, this.memberList, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddMemberInGroupState();
  }
}

class _AddMemberInGroupState extends State<AddMemberInGroup> {
  List<Map<String, dynamic>> oldMemberList = [];
  List<Map<String, dynamic>> allUserList = [];
  List<Map<String, dynamic>> userForAddedList = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<Map<String, dynamic>> selectedMemberList = [];

  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  var etSearch = TextEditingController();

  Set<String> selectedUserIds = {};

  void getUserList() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final querySnapshot = await fireStore
        .collection('users')
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .get();

    allUserList = querySnapshot.docs.map((doc) => doc.data()).toList();

    userForAddedList = allUserList.where((user) {
      return !oldMemberList.any((selected) => selected['uid'] == user['uid']);
    }).toList();

    if (userForAddedList.isEmpty) {
      ErrorHelper.showSnackBar("No more user to added", context);
      Navigator.pop(context);
    }

    filteredUsers = userForAddedList;

    setState(() {});
  }

  void searchUser(String query) {
    if (query.isEmpty) {
      filteredUsers = List.from(userForAddedList);
    } else {
      filteredUsers = userForAddedList.where((user) {
        final name = user['name'].toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        return name.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase());
      }).toList();
    }
    setState(() {});
  }

  void addUserInGroup() {
    for (int i = 0; i < selectedMemberList.length; i++) {
      oldMemberList.add({
        'name': selectedMemberList[i]['name'],
        'email': selectedMemberList[i]['email'],
        'uid': selectedMemberList[i]['uid'],
        'isAdmin': false,
      });
    }
  }

  void updateGroup() async {
    addUserInGroup();

    showLoaderDialog(context);
    await fireStore.collection('groups').doc(widget.groupId).update({
      'member': oldMemberList,
    });

    for (int i = 0; i < selectedMemberList.length; i++) {
      String uid = selectedMemberList[i]['uid'];
      await fireStore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(widget.groupId)
          .set({
        'name': widget.groupName,
        'groupId': widget.groupId,
        'createdBy': auth.currentUser!.displayName,
        'createdById': auth.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'type': "group"
      });
    }

    var addedUsers = getMemberName().join(" , ");

    ErrorHelper.showSnackBar("new member added successfully", context);

    await memberUpdateMessage(
        "${auth.currentUser!.displayName} added $addedUsers ");

    hideLoader(context);

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => GroupChatScreen(
                widget.groupId, widget.groupName, oldMemberList)));
  }

  List<String> getMemberName() {
    List<String> memberList = [];

    for (var memberMap in selectedMemberList) {
      if (memberMap['name'] != auth.currentUser!.displayName) {
        memberList.add(memberMap['name']);
      }
    }

    return memberList;
  }

  Future<void> memberUpdateMessage(memberUpdateMessage) async {
    Map<String, dynamic> messages = {
      'senderId': auth.currentUser?.uid,
      'senderName': auth.currentUser?.displayName,
      'message': "",
      'message_type': "text",
      'time': FieldValue.serverTimestamp(),
      'memberUpdateMessage': memberUpdateMessage,
    };

    await fireStore
        .collection('group_chatroom')
        .doc(widget.groupId)
        .collection('group_chats')
        .add(messages);
  }

  @override
  void initState() {
    super.initState();
    oldMemberList = widget.memberList;
    getUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyColor.lightGrey,
        floatingActionButton: floatingActionBtn(Icons.check, () {
          if (selectedMemberList.isNotEmpty) {
            updateGroup();
          } else {
            ErrorHelper.showSnackBar("Please select user", context);
          }
        }),
        body: Container(
          margin: const EdgeInsets.only(top: 40, left: 10, right: 10),
          child: Column(
            children: [
              CustomTextField(
                onChanged: (value) {
                  searchUser(value);
                },
                strHint: 'Search name or email',
                controller: etSearch,
                prefixIcon: const Icon(Icons.search),
                radius: 30.0,
                marginLeft: 0,
                marginRight: 0,
                marginTop: 0,
                marginBottom: 0,
              ),
              if (selectedMemberList.isNotEmpty) ...[
                selectedGroupMemberList(),
                const Divider(
                  height: 2,
                  color: MyColor.grey,
                ),
                const SizedBox(
                  height: 10,
                )
              ],
              AllList(),
            ],
          ),
        ));
  }

  Widget selectedGroupMemberList() {
    return Container(
      height: 100,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: selectedMemberList.length,
            itemBuilder: (context, index) {
              var name = selectedMemberList[index]['name'].toString();

              return groupMemberListItem(name, () {});
            }),
      ),
    );
  }

  Widget groupMemberListItem(name, onclick) {
    return InkWell(
      onTap: () {
        onclick();
      },
      child: Container(
          height: 60,
          width: 80,
          margin: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              const CircleAvatar(
                backgroundColor: MyColor.projectColor,
                foregroundColor: MyColor.white,
                radius: 18,
                child: Icon(Icons.person_outline_outlined),
              ),
              Text(
                name,
                style: const TextStyle(
                    color: MyColor.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )),
    );
  }

  Widget AllList() {
    return Expanded(
      child: Container(
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                var name = filteredUsers[index]['name'].toString();
                var email = filteredUsers[index]['email'].toString();

                final user = filteredUsers[index];
                final userId = user['uid'];

                final checkBoxValue = selectedUserIds.contains(userId);

                return listItem(name, email, checkBoxValue, () {
                  setState(() {
                    if (checkBoxValue) {
                      selectedUserIds.remove(userId);
                      selectedMemberList.removeWhere((u) => u['uid'] == userId);
                    } else {
                      selectedUserIds.add(userId);
                      selectedMemberList.add(user);
                    }
                  });
                });
              }),
        ),
      ),
    );
  }

  Widget listItem(name, email, checkBoxValue, onclick) {
    return InkWell(
      onTap: () {
        onclick();
      },
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: MyColor.projectColor,
                    foregroundColor: MyColor.white,
                    radius: 22,
                    child: Icon(Icons.person_outline_outlined),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                              color: MyColor.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          email,
                          style: const TextStyle(color: MyColor.black),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() => checkBoxValue = !checkBoxValue);
                },
                child: Container(
                  width: 25,
                  height: 25,
                  //   padding: EdgeInsets.all(4), // 👈 REAL padding
                  decoration: BoxDecoration(
                    color: checkBoxValue
                        ? MyColor.projectColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: MyColor.projectColor,
                      width: 2,
                    ),
                  ),
                  child: checkBoxValue
                      ? const Icon(Icons.check, size: 16, color: MyColor.white)
                      : null,
                ),
              ),
            ],
          )),
    );
  }
}
