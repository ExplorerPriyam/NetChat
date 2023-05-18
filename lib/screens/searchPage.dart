import 'package:chatapp/models/ChatRoomModel.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/screens/chatroompage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/main.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  ChatRoomModel? chatRoom;
  Future<ChatRoomModel?> getChatRoom(UserModel targetUser) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      //Fetch the existing
      //Chatroom fetch
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatroom;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: Text('New Chat Room'),
        backgroundColor: Colors.red,
      ));
      ChatRoomModel newChatroom = ChatRoomModel(
          chatroomid: uuid.v1(),
          lastMessage: "",
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true
          },
          users: [widget.userModel.uid.toString(), targetUser.uid.toString()],
          createdon: DateTime.now());
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());
      chatRoom = newChatroom;
    }

    return chatRoom;
  }

  var searchc = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 198, 76),
        title: Text('Search Friends'),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            TextField(
              controller: searchc,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Search User by Phone Number'),
            ),
            SizedBox(
              height: 14,
            ),
            SizedBox(
              height: 30,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 255, 198, 76))),
                onPressed: () {
                  setState(() {});
                },
                child: Text('Search'),
              ),
            ),
            SizedBox(
              height: 14,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where("phoneno", isEqualTo: searchc.text)
                  .where("phoneno", isNotEqualTo: widget.userModel.phoneno)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot datasnapshot = snapshot.data as QuerySnapshot;
                    if (datasnapshot.docs.length > 0) {
                      Map<String, dynamic> userMap =
                          datasnapshot.docs[0].data() as Map<String, dynamic>;
                      UserModel searchedUser = UserModel.fromMap(userMap);
                      return Card(
                          child: ListTile(
                        tileColor: Color.fromARGB(255, 120, 251, 100),
                        onTap: () async {
                          ChatRoomModel? chatRoomModel =
                              await getChatRoom(searchedUser);
                          if (chatRoomModel != null) {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ChatroomPage(
                                targetUser: searchedUser,
                                userModel: widget.userModel,
                                firebaseUser: widget.firebaseUser,
                                chatroom: chatRoomModel,
                              );
                            }));
                          }
                        },
                        leading:
                            Image.network(searchedUser.profilepic.toString()),
                        title: Text(searchedUser.fullname.toString()),
                        subtitle: Text(searchedUser.email.toString()),
                        trailing: Icon(Icons.keyboard_arrow_right_outlined),
                      ));
                    } else {
                      return Text('No Results Found');
                    }
                  } else if (snapshot.hasError) {
                    return Text('Error Occured');
                  } else {
                    return Text('No Results Found');
                  }
                } else {
                  return CircularProgressIndicator();
                }
              },
            )
          ],
        ),
      )),
    );
  }
}
