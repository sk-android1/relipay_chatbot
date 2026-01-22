import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:relipay_chatbot/ui_screen/group_info_screen.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/error_helper.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_color.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_widget.dart';

class GroupChatScreen extends StatefulWidget {
  String groupId;
  String groupName;
  List<Map<String, dynamic>> memberList;

  GroupChatScreen(
    this.groupId,
    this.groupName,
    this.memberList, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _GroupChatScreenState();
  }
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  TextEditingController etMessage = TextEditingController();
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  final ScrollController _scrollController = ScrollController();

  void onSendMessage() async {
    if (etMessage.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        'senderId': auth.currentUser?.uid,
        'senderName': auth.currentUser?.displayName,
        'message': etMessage.text,
        'memberUpdateMessage': "",
        'message_type': "text",
        'time': FieldValue.serverTimestamp(),
      };
      await fireStore
          .collection('group_chatroom')
          .doc(widget.groupId)
          .collection('group_chats')
          .add(messages);
      etMessage.clear();
      scrollToBottomIfNeeded();
    } else {
      ErrorHelper.showSnackBar("enter message", context);
    }
  }

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate.year == today.year &&
        messageDate.month == today.month &&
        messageDate.day == today.day) {
      // Today → show time
      //  return DateFormat('hh:mm a').format(dateTime);
      return "Today";
    } else if (messageDate.year == yesterday.year &&
        messageDate.month == yesterday.month &&
        messageDate.day == yesterday.day) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Older → date
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
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

  List<String> getMemberName() {
    List<String> memberList = [];

    for (var memberMap in widget.memberList) {
      if (memberMap['name'] != auth.currentUser!.displayName) {
        memberList.add(memberMap['name']);
      }
    }

    return memberList;
  }

  void scrollToBottomIfNeeded() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    // Scroll ONLY if content is larger than screen
    if (position.maxScrollExtent > 0) {
      _scrollController.animateTo(
        position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: MyColor.lightGrey,
      body: Column(
        children: [
          Container(
              margin: const EdgeInsets.only(top: 35),
              padding: const EdgeInsets.all(10),
              color: MyColor.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: MyColor.lightGrey,
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.65,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.groupName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: MyColor.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              getMemberName().join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: MyColor.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  floatingActionBtn(Icons.info_outline, size: 42.0, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GroupInfoScreen(
                                widget.groupId,
                                widget.groupName,
                                widget.memberList)));
                  })
                ],
              )),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('group_chatroom')
                  .doc(widget.groupId)
                  .collection('group_chats')
                  .orderBy('time', descending: false)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {

                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return const Center(child: CircularProgressIndicator());
                // }

                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages'));
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollToBottomIfNeeded();
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    final preData = index > 0
                        ? snapshot.data!.docs[index - 1].data()
                            as Map<String, dynamic>
                        : null;

                    String message = data['message'];
                    String memberUpdateMessage = data['memberUpdateMessage'];

                    return message.isNotEmpty
                        ? messages(size, data, preData)
                        : widgetMemberUpdateMsg(memberUpdateMessage);
                  },
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: etMessage,
                    minLines: 1,
                    maxLines: 5, // auto expand
                    decoration: InputDecoration(
                      hintText: "Enter Message",
                      filled: true,
                      fillColor: MyColor.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                CircleAvatar(
                  radius: 22,
                  backgroundColor: MyColor.projectColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        scrollToBottomIfNeeded();
                      });
                      onSendMessage();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget messages(
    Size size,
    Map<String, dynamic> map,
    Map<String, dynamic>? previousMap,
  ) {
    Timestamp? timestamp = map['time'];

    DateTime? currentTime;
    if (timestamp != null) {
      currentTime = timestamp.toDate();
    } else {
      currentTime = DateTime.now();
    }

    bool showDateHeader = true;

    if (previousMap != null) {
      DateTime previousTime = previousMap['time'].toDate();

      showDateHeader = currentTime.year != previousTime.year ||
          currentTime.month != previousTime.month ||
          currentTime.day != previousTime.day;
    }

    return Column(
      children: [
        if (showDateHeader)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
                color: MyColor.white, borderRadius: BorderRadius.circular(8)),
            child: Text(
              formatDateTime(currentTime),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Container(
          margin: map['senderName'] == auth.currentUser?.displayName
              ? const EdgeInsets.only(left: 80)
              : const EdgeInsets.only(right: 80),
          alignment: map['senderName'] == auth.currentUser?.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: map['senderName'] == auth.currentUser?.displayName
                  ? MyColor.lightGreen
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            margin: const EdgeInsets.all(5),
            child: map['message'].toString().length < 30
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (map['senderName'] !=
                                auth.currentUser?.displayName) ...[
                              Text(
                                map['senderName'],
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: MyColor.blue,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                            Text(
                              map['message'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('hh:mm a').format(currentTime),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (map['senderName'] !=
                          auth.currentUser?.displayName) ...[
                        Text(
                          map['senderName'],
                          style: const TextStyle(
                              fontSize: 14,
                              color: MyColor.blue,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                      Text(
                        map['message'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          DateFormat('hh:mm a').format(currentTime),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget widgetMemberUpdateMsg(text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
          color: MyColor.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: MyColor.grey, // 👈 IMPORTANT
              blurRadius: 2,
              spreadRadius: 1,
              offset: Offset(0, 1),
               )
          ]),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: MyColor.darkGrey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
