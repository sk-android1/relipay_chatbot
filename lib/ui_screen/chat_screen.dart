import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/error_helper.dart';
import 'package:relipay_chatbot/ui_screen/ui_helper/my_color.dart';

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

  bool isTopContainer1Visible = true;
  Set<String> selectedMessageIds = {};
  bool isSelectionMode = false;


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

  Future<void> deleteChatForMe({required String chatRoomId, required String messageId,}) async {
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

  Future<void> deleteChatForEveryone({required String chatRoomId, required String messageId,}) async {
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
    final size = MediaQuery
        .of(context)
        .size;

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
            isTopContainer1Visible
                ? topContainer1()
                : topContainer2(),
            // Container(
            //   margin: const EdgeInsets.only(top: 35),
            //   padding: const EdgeInsets.all(10),
            //   color: MyColor.white,
            //   child: Row(
            //     children: [
            //       CircleAvatar(
            //         radius: 18,
            //         backgroundColor: MyColor.lightGrey,
            //         child: IconButton(
            //           icon: const Icon(Icons.arrow_back, color: Colors.white),
            //           onPressed: () {
            //             Navigator.pop(context,true);
            //
            //           },
            //         ),
            //       ),
            //       Column(
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         children: [
            //           StreamBuilder(
            //               stream: fireStore
            //                   .collection('users')
            //                   .doc(widget.userMap['uid'])
            //                   .snapshots(),
            //               builder: (context, snapshot) {
            //                 if (!snapshot.hasData || snapshot.data == null) {
            //                   return const SizedBox(); // or loading indicator
            //                 }
            //
            //                 Timestamp? timestamp = snapshot.data!['last_seen'];
            //
            //                 DateTime? currentTime;
            //                 if (timestamp != null) {
            //                   currentTime = timestamp.toDate();
            //                 } else {
            //                   currentTime =
            //                       DateTime.now(); // fallback if time is missing
            //                 }
            //                 return Container(
            //                   margin: const EdgeInsets.only(left: 10),
            //                   alignment: Alignment.centerLeft,
            //                   child: Column(
            //                     mainAxisAlignment: MainAxisAlignment.start,
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     children: [
            //                       Text(
            //                         widget.userMap['name'],
            //                         style: const TextStyle(
            //                             color: MyColor.black,
            //                             fontSize: 18,
            //                             fontWeight: FontWeight.w500),
            //                       ),
            //                       Text(
            //                         snapshot.data!['status'] == "online"
            //                             ? 'online'
            //                             : "last seen ${formatDateTime2(currentTime)}",
            //                         style: const TextStyle(color: MyColor.black),
            //                       ),
            //                     ],
            //                   ),
            //                 );
            //               })
            //         ],
            //       )
            //     ],
            //   ),
            // ),
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
                      final preData = index > 0                               // chat date filtering
                          ? snapshot.data!.docs[index - 1].data()
                      as Map<String, dynamic>
                          : null;

                      var deleteText = "";

                      if (data['senderName'] == auth.currentUser?.displayName) {
                        deleteText = "You delete this message";
                      } else {
                        deleteText = "This message has been deleted";
                      }

                      List deletedFor = data['deletedFor'] ?? [];
                      bool isDeletedForMe = deletedFor.contains(auth.currentUser!.uid);
                      var strDocId = snapshot.data!.docs[index].id;

                      final isSelected = selectedMessageIds.contains(strDocId);

                      return GestureDetector(

                        onLongPress: () {
                         setState(() {
                           isSelectionMode = true;
                           selectedMessageIds.add(strDocId);
                           isTopContainer1Visible = false;
                         });



                          // data['isDeleted']
                          //     ?
                          // deletedChatRemoveConfirmDialog(
                          //   context, "Confirmation!!!",
                          //   "Are you sure you want to remove this",
                          //       () {
                          //     deleteChatForMe(
                          //         chatRoomId: widget.chatRoomId,
                          //         messageId: strDocId);
                          //   },
                          // )
                          //     :
                          //
                          // data['senderName'] == auth.currentUser?.displayName
                          //     ?
                          // messageDeletedConfirmDialog(
                          //     context, "Confirmation!!!",
                          //     "Are you sure you want to delete ${data['message']}",
                          //         () {
                          //       deleteChatForMe(
                          //           chatRoomId: widget.chatRoomId,
                          //           messageId: strDocId);
                          //     }, () {
                          //   deleteChatForEveryone(
                          //       chatRoomId: widget.chatRoomId,
                          //       messageId: strDocId);
                          // })
                          //     :
                          // deleteForMeConfirmDialog(context, "Confirmation!!!",
                          //   "Are you sure you want to delete ${data['message']}",
                          //       () {
                          //     deleteChatForMe(
                          //         chatRoomId: widget.chatRoomId,
                          //         messageId: strDocId);
                          //   },
                          // );

                        },
                        onTap: (){
                          if (isSelectionMode) {
                            setState(() {
                              if (isSelected) {
                                selectedMessageIds.remove(strDocId);
                              } else {
                                selectedMessageIds.add(strDocId);
                              }

                              // Exit selection mode if nothing selected
                              if (selectedMessageIds.isEmpty) {
                                isSelectionMode = false;
                                isTopContainer1Visible = true;
                              }
                            });
                          } else {
                            // Normal message tap
                          }
                        },
                        child: messages(size, data, preData, isDeletedForMe,
                            deleteText,isClicked: isSelected),

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

  Widget topContainer1() {
    return Container(
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
                Navigator.pop(context, true);
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
    );
  }

  Widget topContainer2() {
    return Container(
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
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      isTopContainer1Visible = true;
                      selectedMessageIds.clear();
                      ErrorHelper.showSnackBar(selectedMessageIds.toString(), context);
                    });
                  },
                ),
              ),
              const SizedBox(width: 10,),
             if(selectedMessageIds.isNotEmpty)...[
               Text(selectedMessageIds.length.toString(), style: const TextStyle(fontWeight: FontWeight.w500, color: MyColor.black, fontSize: 20),)
             ]
            ],
          ),
          Row(
            children: [

              if(selectedMessageIds.length == 1)...[
                 IconButton(onPressed: (){}, icon: Image.asset("assets/images/reply.png", height: 22,width: 22,)),
                const SizedBox(width: 8,),
              ],

              IconButton(onPressed: (){}, icon: Image.asset("assets/images/delete.png", height: 22,width: 22,)),
              const SizedBox(width: 8,),
              IconButton(onPressed: (){}, icon: Image.asset("assets/images/forward.png", height: 22,width: 22,)),
              const SizedBox(width: 8,),
              IconButton(onPressed: (){}, icon: Image.asset("assets/images/copy.png", height: 22,width: 22,)),
            ],
          )
        ],
      )
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, Map<String, dynamic>? previousMap, bool isDeletedForMe, String deleteText, { bool isClicked = false}) {
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
            color: isClicked?MyColor.lightGreen3:MyColor.transparent,
            margin: const EdgeInsets.symmetric(vertical: 2),
            child: Container(
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
                  child: map['message']
                      .toString()
                      .length < 30
                      ? map['isDeleted']
                      ? Text(deleteText)
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
                      ? Text(deleteText)
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
          ),
        ]
      ],
    );
  }

}
