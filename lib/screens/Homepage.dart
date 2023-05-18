import 'dart:ffi';

import 'package:chatapp/models/ChatRoomModel.dart';
import 'package:chatapp/models/FirebaseHelper.dart';
import 'package:chatapp/screens/chatroompage.dart';
import 'package:chatapp/screens/searchPage.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/models/UserModel.dart';
import 'dart:io';
import 'package:chatapp/screens/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:chatapp/screens/UpdateProfile.dart';

class Homepage extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseuser;

  const Homepage(
      {super.key, required this.userModel, required this.firebaseuser});
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 198, 76),
        title: Text('Mini Mail'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: LottieBuilder.network(
          'https://assets9.lottiefiles.com/packages/lf20_fnitdsu4.json',
          height: 60,
          width: 80,
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return UpdateProfile(
                      userModel: widget.userModel,
                      fireBaseUser: widget.firebaseuser);
                }));
              },
              child: Text('Update info')),
          IconButton(
              onPressed: () async {
                FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return Login();
                }));
              },
              icon: Icon(Icons.exit_to_app_rounded)),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: Color.fromARGB(255, 245, 245, 245)),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("users", arrayContains: widget.userModel!.uid)
                .orderBy("createdon")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomsnapshot =
                      snapshot.data as QuerySnapshot;
                  return ListView.builder(
                    itemCount: chatRoomsnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel? chatRoomModel = ChatRoomModel.fromMap(
                          chatRoomsnapshot.docs[index].data()
                              as Map<String, dynamic>);
                      Map<String, dynamic> participants =
                          chatRoomModel.participants!;
                      List<String> participantskeys =
                          participants.keys.toList();
                      participantskeys.remove(widget.userModel!.uid);
                      return FutureBuilder(
                          future: FirebaseHelper.getUserModelbyId(
                              participantskeys[0]),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              UserModel targetUser = snapshot.data as UserModel;
                              return Card(
                                child: ListTile(
                                  onTap: () async {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return ChatroomPage(
                                            targetUser: targetUser,
                                            chatroom: chatRoomModel,
                                            userModel: widget.userModel,
                                            firebaseUser: widget.firebaseuser);
                                      },
                                    ));
                                  },
                                  tileColor: Color.fromARGB(255, 90, 161, 255),
                                  title: Text(
                                    targetUser.fullname!.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color:
                                            Color.fromARGB(234, 245, 225, 4)),
                                  ),
                                  leading: CircleAvatar(
                                    radius: 28,
                                    backgroundImage: NetworkImage(
                                        targetUser.profilepic.toString()),
                                  ),
                                  subtitle: (chatRoomModel.lastMessage
                                              .toString() !=
                                          '')
                                      ? Text(
                                          chatRoomModel.lastMessage.toString(),
                                          style: TextStyle(color: Colors.white),
                                        )
                                      : Text(
                                          'Say Hi to Your New Friend 👋',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                  trailing: Icon(Icons.chat_rounded),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          });
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Center(
                    child: Text("No Chats"),
                  );
                }
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
                userModel: widget.userModel!,
                firebaseUser: widget.firebaseuser!);
          }));
        },
        child: LottieBuilder.network(
            'https://assets10.lottiefiles.com/packages/lf20_nhv85sha.json'),
      ),
    );
  }
}
