import 'package:chatapp/models/FirebaseHelper.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:uuid/uuid.dart';
import 'package:chatapp/screens/splashscreen.dart';
import 'package:chatapp/LoggedinSpalash.dart';

var uuid = Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelbyId(currentUser.uid);
    if (thisUserModel != null) {
      runApp(MyappLoggedIn(
        firebaseUser: currentUser,
        userModel: thisUserModel,
      ));
    }
  } else {
    runApp(Myapp());
  }
}

class Myapp extends StatefulWidget {
  const Myapp({super.key});

  @override
  State<Myapp> createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Splashscreen());
  }
}

//LoggedIn

//LoggedIn
class MyappLoggedIn extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;

  const MyappLoggedIn(
      {super.key, required this.userModel, required this.firebaseUser});
  @override
  State<MyappLoggedIn> createState() => _MyappLoggedInState();
}

class _MyappLoggedInState extends State<MyappLoggedIn> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpalashLoggedIn(
          userModel: widget.userModel, firebaseUser: widget.firebaseUser),
    );
  }
}
