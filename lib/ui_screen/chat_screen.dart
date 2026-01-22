import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:relipay_chatbot/my_utils/my_dialog.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/error_helper.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_color.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_widget.dart';

import 'HomeScreen.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  const ChatScreen(
      {super.key, required this.userMap, required this.chatRoomId});

  @override
  State<StatefulWidget> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController etMessage = TextEditingController();
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  final ScrollController _scrollController = ScrollController();

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

  void onSendChat() async {
    if (etMessage.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        'senderId': auth.currentUser?.uid,
        'senderName': auth.currentUser?.displayName,
        'message': etMessage.text,
        'message_type': "text",
        'time': FieldValue.serverTimestamp(),
        'deletedFor': [],
        "isDeleted": false,
        "deletedAt": null
      };
      await fireStore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
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

  /////////  chat delete

  Future<void> deleteChatForMe({
    required String chatRoomId,
    required String messageId,
  }) async {
    final uid = auth.currentUser!.uid;

    await fireStore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(messageId)
        .update({
      'deletedFor': FieldValue.arrayUnion([uid]),
    });
    setState(() {});
  }

  Future<void> deleteChatForEveryone({
    required String chatRoomId,
    required String messageId,
  }) async {
    await fireStore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(messageId)
        .update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: MyColor.lightGrey,
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 35),
              padding: const EdgeInsets.all(10),
              color: MyColor.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: MyColor.lightGrey,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context,true);

                      },
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      StreamBuilder(
                          stream: fireStore
                              .collection('users')
                              .doc(widget.userMap['uid'])
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data == null) {
                              return const SizedBox(); // or loading indicator
                            }

                            Timestamp? timestamp = snapshot.data!['last_seen'];

                            DateTime? currentTime;
                            if (timestamp != null) {
                              currentTime = timestamp.toDate();
                            } else {
                              currentTime =
                                  DateTime.now(); // fallback if time is missing
                            }
                            return Container(
                              margin: const EdgeInsets.only(left: 10),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.userMap['name'],
                                    style: const TextStyle(
                                        color: MyColor.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    snapshot.data!['status'] == "online"
                                        ? 'online'
                                        : "last seen ${formatDateTime2(currentTime)}",
                                    style: const TextStyle(color: MyColor.black),
                                  ),
                                ],
                              ),
                            );
                          })
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chatroom')
                    .doc(widget.chatRoomId)
                    .collection('chats')
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

                      var deleteText = "";

                      if( data['senderName'] == auth.currentUser?.displayName){
                        deleteText = "You delete this message";
                      }else{
                        deleteText = "This message has been deleted";
                      }

                      List deletedFor = data['deletedFor'] ?? [];
                      bool isDeletedForMe =
                          deletedFor.contains(auth.currentUser!.uid);

                      var strDocId = snapshot.data!.docs[index].id;

                      return GestureDetector(
                        onLongPress: () {

                          data['isDeleted']
                          ?
                          deletedChatRemoveConfirmDialog(context, "Confirmation!!!", "Are you sure you want to remove this",
                                () {
                              deleteChatForMe(
                                  chatRoomId: widget.chatRoomId,
                                  messageId: strDocId);
                            },
                          )
                          :

                          data['senderName'] == auth.currentUser?.displayName
                              ?
                          messageDeletedConfirmDialog(context, "Confirmation!!!",
                              "Are you sure you want to delete ${data['message']}",
                                  () {
                                deleteChatForMe(
                                    chatRoomId: widget.chatRoomId,
                                    messageId: strDocId);
                              }, () {
                                deleteChatForEveryone(
                                    chatRoomId: widget.chatRoomId,
                                    messageId: strDocId);
                              })
                              :
                          deleteForMeConfirmDialog(context, "Confirmation!!!", "Are you sure you want to delete ${data['message']}",
                                  () {
                                deleteChatForMe(
                                    chatRoomId: widget.chatRoomId,
                                    messageId: strDocId);
                              },
                          );
                        },
                        child: messages(size, data, preData, isDeletedForMe, deleteText),
                      );
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
                        onSendChat();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, Map<String, dynamic>? previousMap, bool isDeletedForMe, String deleteText) {
    //  DateTime currentTime = map['time'].toDate();

    Timestamp? timestamp = map['time'];

    DateTime? currentTime;
    if (timestamp != null) {
      currentTime = timestamp.toDate();
    } else {
      currentTime = DateTime.now(); // fallback if time is missing
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
        // DATE HEADER
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

        //  chat ui
        if (!isDeletedForMe) ...[
          Container(
            margin: map['senderName'] == auth.currentUser?.displayName
                ? const EdgeInsets.only(left: 100)
                : const EdgeInsets.only(right: 100),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                margin: const EdgeInsets.all(5),
                child: map['message'].toString().length < 30
                    ? map['isDeleted']
                        ?  Text(deleteText)
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  map['message'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('hh:mm a').format(currentTime),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          )
                    : map['isDeleted']
                        ?  Text(deleteText)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                map['message'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                DateFormat('hh:mm a').format(currentTime),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          )),
          ),
        ]
      ],
    );
  }
}
