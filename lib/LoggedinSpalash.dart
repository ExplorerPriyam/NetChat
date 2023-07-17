import 'dart:async';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/screens/Homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SpalashLoggedIn extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;

  const SpalashLoggedIn(
      {super.key, required this.userModel, required this.firebaseUser});
  @override
  State<SpalashLoggedIn> createState() => _SpalashLoggedInState();
}

class _SpalashLoggedInState extends State<SpalashLoggedIn> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Homepage(
            userModel: widget.userModel, firebaseuser: widget.firebaseUser);
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LottieBuilder.asset('assets/lottie.json'),
              Text(
                'Net Chat',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      )),
    );
  }
}
