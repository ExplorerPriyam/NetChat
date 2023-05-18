import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/screens/Homepage.dart';
import 'package:chatapp/screens/Signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var emailc = TextEditingController();
  var passc = TextEditingController();

  void login(String email, String pass) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailc.text.trim(), password: passc.text.trim());
    } on FirebaseAuthException catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: Text(ex.toString()),
        backgroundColor: Colors.red,
      ));
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: Text('Login Sucessfull'),
        backgroundColor: Colors.blue,
      ));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Homepage(userModel: userModel, firebaseuser: credential!.user);
      }));
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
                'Mini Mail',
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
              SizedBox(height: 30),
              SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                      onPressed: () {
                        login(emailc.text.toString(), passc.text.toString());
                      },
                      child: Text('Login')))
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
              "If you Don't have an Accout😥",
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
              ),
            ),
            SizedBox(
              height: 30,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Signup();
                    }));
                  },
                  child: Text('Sign Up')),
            )
          ],
        ),
      ),
    );
  }
}
