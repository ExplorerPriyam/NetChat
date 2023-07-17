import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/screens/CompleteProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  var emailc = TextEditingController();
  bool sucess = false;
  var passc = TextEditingController();
  var cpassc = TextEditingController();
  void signUp(String email, String password) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newuser = new UserModel(
          uid: uid,
          email: emailc.text.trim(),
          fullname: '',
          profilepic: '',
          phoneno: '');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(newuser.toMap())
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
          content: Text('New User Created'),
          backgroundColor: Colors.blue,
        ));
        setState(() {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return CompleteProfile(
                  userModel: newuser, firebaseUser: credential!.user!);
            },
          ));
        });
      });
    }
  }

  checkValue() async {
    if (emailc.text == '' || passc.text == '' || cpassc.text == '') {
      return {
        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
          content: Text('Empty'),
          backgroundColor: Colors.red,
        ))
      };
    } else if (passc.value != cpassc.value) {
      return {
        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
          content: Text('password missmatch'),
          backgroundColor: Colors.red,
        ))
      };
    } else {
      return {
        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
          content: Text('Email Password combination ok'),
          backgroundColor: Colors.blue,
        )),
        signUp(emailc.text.trim(), passc.text.trim())
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 35),
        child: Center(
          child: SingleChildScrollView(
            child: Column(children: [
              Text(
                'Net Chat',
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 35,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: emailc,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Email'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: passc,
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Password'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                obscureText: true,
                controller: cpassc,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm Password'),
              ),
              SizedBox(height: 30),
              SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                      onPressed: () async {
                        checkValue();
                        //    Navigator.pushNamed(context, 'CompleteProfile');
                      },
                      child: Text('SignUp')))
            ]),
          ),
        ),
      )),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an Account ☺️",
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
              ),
            ),
            SizedBox(
              height: 30,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Login')),
            )
          ],
        ),
      ),
    );
    ;
  }
}
