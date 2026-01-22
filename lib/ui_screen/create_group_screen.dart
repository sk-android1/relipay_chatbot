import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:relipay_chatbot/ui_screen/HomeScreen.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/custom_text_field.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/error_helper.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_color.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_widget.dart';

import '../my_utils/my_dialog.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateGroupScreenState();
  }
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  List<Map<String, dynamic>> userList = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<Map<String, dynamic>> selectedMemberList = [];
  List<Map<String, dynamic>> createGroupMemberList = [];

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  var etSearch = TextEditingController();
  var etGroupName = TextEditingController();
  Set<String> selectedUserIds = {};

  void getUserList() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final querySnapshot = await firestore
        .collection('users')
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .get();

    userList = querySnapshot.docs.map((doc) => doc.data()).toList();
    filteredUsers = userList;

    setState(() {});
  }

  void searchUser(String query) {
    if (query.isEmpty) {
      filteredUsers = List.from(userList);
    } else {
      filteredUsers = userList.where((user) {
        final name = user['name'].toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        return name.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase());
      }).toList();
    }
    setState(() {});
  }

  Future<void> addCurrentUserInGroup() async {
    createGroupMemberList.clear();

    final userDoc =
        await firestore.collection('users').doc(auth.currentUser!.uid).get();

    createGroupMemberList.add({
      'name': userDoc['name'],
      'email': userDoc['email'],
      'uid': userDoc['uid'],
      'isAdmin': true,
    });

    for (int i = 0; i < selectedMemberList.length; i++) {
      createGroupMemberList.add({
        'name': selectedMemberList[i]['name'],
        'email': selectedMemberList[i]['email'],
        'uid': selectedMemberList[i]['uid'],
        'isAdmin': false,
      });
    }
  }

  void createGroup() async {
    showLoaderDialog(context);

    await addCurrentUserInGroup();

    String groupId = firestore.collection('groups').doc().id;

    await firestore.collection('groups').doc(groupId).set({
      'member': createGroupMemberList,
      'name': etGroupName.text.trim(),
      'groupId': groupId,
      'createdBy': auth.currentUser!.displayName,
      'createdById': auth.currentUser!.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'type': "group"
    });

    for (int i = 0; i < createGroupMemberList.length; i++) {
      String uid = createGroupMemberList[i]['uid'];
      await firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(groupId)
          .set({
        'name': etGroupName.text,
        'groupId': groupId,
        'createdBy': auth.currentUser!.displayName,
        'createdById': auth.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'type': "group"
      });
    }

    ErrorHelper.showSnackBar("Group created successfully", context);
    hideLoader(context);
    Navigator.pop(context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyColor.lightGrey,
        floatingActionButton: floatingActionBtn(Icons.check, () {
          if (etGroupName.text.isNotEmpty) {
            createGroup();
          } else {
            ErrorHelper.showSnackBar('Please enter group name', context);
          }
        }),
        body: Container(
          margin: const EdgeInsets.only(top: 40, left: 10, right: 10),
          child: Column(
            children: [
              if (selectedMemberList.isNotEmpty) ...[
                CustomTextField(
                  strHint: 'Enter group name',
                  controller: etGroupName,
                ),
                selectedGroupMemberList(),
                const Divider(
                  height: 1,
                  color: MyColor.grey,
                )
              ],
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: CustomTextField(
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
              ),
              allList(),
            ],
          ),
        ));
  }

  Widget selectedGroupMemberList() {
    return Container(
      height: 80,
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

  Widget allList() {
    return Expanded(
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

// Widget floatingActionBtn() {
//   return Positioned(
//     right: 20,
//     bottom: 20,
//     child: FloatingActionButton(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(30), // change radius here
//       ),
//       backgroundColor: MyColor.projectColor,
//       foregroundColor: MyColor.white,
//       onPressed: () {
//
//         if(etGroupName.text.isNotEmpty){
//           createGroup();
//         }
//         else{
//           ErrorHelper.showSnackBar('Please enter group name', context);
//         }
//
//
//       },
//       child: const Icon(Icons.check),
//
//     ),
//   );
// }
}
