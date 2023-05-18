import 'package:chatapp/main.dart';
import 'package:chatapp/models/MessageModel.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/models/ChatRoomModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatroomPage extends StatefulWidget {
  final UserModel? targetUser;
  final ChatRoomModel? chatroom;
  final UserModel? userModel;
  final User? firebaseUser;

  const ChatroomPage(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  var messagec = TextEditingController();
  void sendMessage() async {
    String msg = messagec.text.trim();
    messagec.clear();
    if (msg != '') {
      MessageModel newMessage = MessageModel(
          messageId: uuid.v1(),
          sender: widget.userModel!.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom!.chatroomid)
          .collection("messages")
          .doc(newMessage.messageId)
          .set(newMessage.toMap());
      widget.chatroom!.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom!.chatroomid)
          .set(widget.chatroom!.toMap());
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.brown,
            backgroundImage:
                NetworkImage(widget.targetUser!.profilepic.toString()),
          ),
          SizedBox(
            width: 10,
          ),
          Text(widget.targetUser!.fullname.toString())
        ]),
      ),
      body: SafeArea(
          child: Container(
        child: Column(
          children: [
            Expanded(
                child: Container(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .doc(widget.chatroom!.chatroomid)
                    .collection("messages")
                    .orderBy("createdon", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;
                      return ListView.builder(
                        reverse: true,
                        itemCount: dataSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          MessageModel currentMessage = MessageModel.fromMap(
                              dataSnapshot.docs[index].data()
                                  as Map<String, dynamic>);
                          return Row(
                            mainAxisAlignment:
                                (currentMessage.sender == widget.userModel!.uid)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            children: [
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: 2),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: (currentMessage.sender ==
                                              widget.userModel!.uid)
                                          ? Color.fromARGB(255, 232, 134, 240)
                                          : Color.fromARGB(255, 168, 219, 85)),
                                  child: Row(
                                    children: [
                                      Text(
                                        currentMessage.text.toString(),
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  )),
                            ],
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            'An error Ocurred! Please check your Internet'),
                      );
                    } else {
                      return Center(
                        child: Text("Say hi to Your new Friend"),
                      );
                    }
                  } else {
                    return Container();
                  }
                },
              ),
            )),
            Container(
              color: Colors.grey[350],
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  Flexible(
                      child: TextField(
                          maxLines: null,
                          controller: messagec,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter Message'))),
                  IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.secondary,
                      ))
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
