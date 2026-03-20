import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:relipay_chatbot/my_utils/my_dialog.dart';
import 'package:relipay_chatbot/notification_service.dart';
import 'package:relipay_chatbot/ui_screen/chat_screen.dart';
import 'package:relipay_chatbot/ui_screen/create_group_screen.dart';
import 'package:relipay_chatbot/ui_screen/login_with_mobile.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/custom_text_field.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/error_helper.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_color.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_widget.dart';

import 'group_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  var etSearch = TextEditingController();
  Map<String, dynamic> userMap = {};

  List<Map<String, dynamic>> userList = [];
  List<Map<String, dynamic>> groupList = [];
  List<Map<String, dynamic>> mergedList = [];
  List<Map<String, dynamic>> filteredUsers = [];

  var currentUser = "";

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  Future logout() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    showLoaderDialog(context);
    try {
      await setStatus("offline");
      await lastSeen();
      await auth.signOut();

      hideLoader(context);

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginWithMobileNo()));
    } catch (e) {
      hideLoader(context);
      ErrorHelper.showSnackBar("$e", context);
    }
  }

  // String chatRoomId(String user1,String user2){
  //   if(user1[0].toLowerCase().codeUnits[0] > user2.toLowerCase().codeUnits[0]){
  //     return '$user1$user2';
  //   }else{
  //    return '$user2$user1';
  //   }
  // }

  String chatRoomId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  void searchUser(String query) {
    if (query.isEmpty) {
      filteredUsers = List.from(mergedList);
    } else {
      filteredUsers = mergedList.where((user) {
        final name = user['name'].toString().toLowerCase();
        final mobileNo = (user['mobile_no'] ?? '').toString().toLowerCase();
        return name.contains(query.toLowerCase()) ||
            mobileNo.contains(query.toLowerCase());
      }).toList();
    }
    setState(() {});
  }

  Future<void> setStatus(status) async {
    await fireStore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .update({'status': status});
  }

  Future<void> lastSeen() async {
    await fireStore.collection('users').doc(auth.currentUser?.uid).update({
      'last_seen': FieldValue.serverTimestamp(),
    });
  }

  // void getUserList() async {
  //   final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  //
  //   final querySnapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .where(FieldPath.documentId, isNotEqualTo: currentUserId)
  //       .get();
  //
  //   userList = querySnapshot.docs.map((doc) => doc.data()).toList();
  //   filteredUsers = userList;
  //   setState(() {
  //
  //   });
  // }

  Future<void> getUserAndGroupList() async {
    try {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   showLoaderDialog(context);
      // });

      currentUser = auth.currentUser!.displayName ?? '';

      final currentUserId = auth.currentUser!.uid;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, isNotEqualTo: currentUserId)
          .get();

      userList = querySnapshot.docs.map((doc) => doc.data()).toList();

      final groupSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('groups')
          .get();

      final groupList = groupSnap.docs.map((doc) => doc.data()).toList();

      mergedList = [
        ...groupList, // groups on top
        ...userList,
      ];

      filteredUsers = mergedList;

      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   hideLoader(context);
      // });

      setState(() {});
    } catch (e) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   hideLoader(context);
      //   ErrorHelper.showSnackBar(e.toString(), context);
      // });
    }
  }

  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final doc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .get();

    if (!doc.exists) return [];

    return List<Map<String, dynamic>>.from(doc['member']);
  }

  String formatDateTime2(DateTime dateTime) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate.year == today.year &&
        messageDate.month == today.month &&
        messageDate.day == today.day) {
      // Today → show time
      return DateFormat('hh:mm a').format(dateTime);
    } else {
      // Older → date
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus("online");
    } else {
      setStatus("offline");
      lastSeen();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    WidgetsBinding.instance.addObserver(this);

    MyNotificationService notificationService = MyNotificationService();
    notificationService.requestNotificationPermission();
    notificationService.getFcmToken();

    notificationService.initNotifications();

    getUserAndGroupList();

    setStatus("online");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyColor.lightGrey,
        floatingActionButton: floatingActionBtn(Icons.group_add_outlined, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateGroupScreen()));
        }),
        body: Container(
          margin: const EdgeInsets.only(top: 40, left: 10, right: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hi, $currentUser',
                    style: const TextStyle(
                        color: MyColor.projectColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      logoutDialog(
                          "LOGOUT", "Are you sure you want to logout", context,
                          () async {
                        Navigator.pop(context);
                        logout();
                      });
                    },
                  )
                ],
              ),
              CustomTextField(
                onChanged: (value) {
                  searchUser(value);
                },
                strHint: 'Search name or mobile number',
                controller: etSearch,
                prefixIcon: const Icon(Icons.search),
                radius: 30.0,
                marginLeft: 0,
                marginRight: 0,
                marginTop: 0,
                marginBottom: 0,
              ),
              allList()
            ],
          ),
        ));
  }

  Widget allList() {
    return Expanded(
      child: Container(
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                var email = filteredUsers[index]['email'].toString();
                var mobileNo = filteredUsers[index]['mobile_no'].toString();
                var lastSeen = filteredUsers[index]['last_seen'];
                var createdBy = filteredUsers[index]['createdBy'].toString();
                var type = filteredUsers[index]['type'].toString();
                var name = filteredUsers[index]['name'].toString();

                var groupId = filteredUsers[index]['groupId'];
                var groupName = filteredUsers[index]['name'];


                Timestamp? timestamp = lastSeen;

                DateTime? currentTime;
                if (timestamp != null) {
                  currentTime = timestamp.toDate();
                } else {
                  currentTime = DateTime.now(); // fallback if time is missing
                }
                String lastTimeStr = formatDateTime2(currentTime);

                if (type == "group") {
                  mobileNo = "Created by $createdBy";
                  lastTimeStr = "";
                }

                return listItem(name, mobileNo, lastTimeStr,type,groupId, () async {
                  String roomId =
                      chatRoomId(auth.currentUser!.displayName ?? '', name);

                  var user = filteredUsers[index];

                  if (type == "group") {
                    var memberList = await getGroupMembers(groupId);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GroupChatScreen(
                                groupId, groupName, memberList)));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(userMap: user, chatRoomId: roomId)));
                  }
                });
              }),
        ),
      ),
    );
  }

  Widget listItem(name, email, lastSeen,userType,groupId, onclick) {
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
                    radius: 22,
                    backgroundColor: MyColor.projectColor,
                    foregroundColor: MyColor.white,
                    child: Icon(Icons.person_outline_outlined),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.78,
                    margin: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Container(
                             width: MediaQuery.of(context).size.width*0.5,
                             child: Text(
                               name,
                               style: const TextStyle(
                                   color: MyColor.black,
                                   fontSize: 18,
                                   fontWeight: FontWeight.w500,),overflow: TextOverflow.ellipsis,
                             ),
                           ),
                           lastMessageTime(name,userType,groupId)
                         ],
                       ),
                        // Text(
                        //   email,
                        //   style: const TextStyle(color: MyColor.black),
                        // )
                        lastMessage(name,userType,groupId)
                      ],
                    ),
                  ),
                ],
              ),
              // Text(lastSeen)

            ],
          )),
    );
  }

  Widget lastMessage( opponentUser, userType,groupId){
   return StreamBuilder(
        stream: userType == "user"
            ?fireStore
            .collection('chatroom')
            .doc(chatRoomId(auth.currentUser!.displayName ?? '', opponentUser))
            .collection('chats')
            .orderBy('time', descending: false)
            .snapshots()
            :fireStore
            .collection('group_chatroom')
            .doc(groupId)
            .collection('group_chats')
            .orderBy('time', descending: false)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text("");
          }

          final data = snapshot.data!.docs.last.data();

          return Container(
            width: MediaQuery.of(context).size.width * 0.75,
            alignment: Alignment.centerLeft,
            child: Text(
              data['message'],
              style: const TextStyle(color: MyColor.darkGrey2,),overflow: TextOverflow.ellipsis,
            ),
          );
        });
  }

  Widget lastMessageTime( opponentUser, userType,groupId){
    return StreamBuilder(
        stream: userType == "user"
            ?fireStore
            .collection('chatroom')
            .doc(chatRoomId(auth.currentUser!.displayName ?? '', opponentUser))
            .collection('chats')
            .orderBy('time', descending: false)
            .snapshots()
            :fireStore
            .collection('group_chatroom')
            .doc(groupId)
            .collection('group_chats')
            .orderBy('time', descending: false)
            .snapshots(),

        builder: (context, snapshot) {



          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text("");
          }

          final data = snapshot.data!.docs.last.data();

          Timestamp? timestamp =  data['time'];

          DateTime? currentTime;
          if (timestamp != null) {
            currentTime = timestamp.toDate();
          } else {
            currentTime = DateTime.now(); // fallback if time is missing
          }
          String lastTimeStr = formatDateTime2(currentTime);

          return Container(
            alignment: Alignment.centerLeft,
            child: Text(
              lastTimeStr,
              style: const TextStyle(color: MyColor.black),
            ),
          );
        });
  }

}
