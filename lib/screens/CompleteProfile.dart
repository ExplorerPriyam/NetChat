import 'dart:io';
import 'package:chatapp/screens/Homepage.dart';
import 'package:chatapp/screens/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;

  const CompleteProfile(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? imageFile;
  var fullnamec = TextEditingController();
  var phonec = TextEditingController();
  void checkValues() {
    if (fullnamec.text == "" || imageFile == null || phonec.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: Text(' Please Fill all Fields'),
        backgroundColor: Colors.red,
      ));
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel!.uid.toString())
        .putFile(imageFile!);
    TaskSnapshot snapshot = await uploadTask;
    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullname = fullnamec.text;
    String? phoneno = phonec.text;
    widget.userModel!.fullname = fullname;
    widget.userModel!.profilepic = imageUrl;
    widget.userModel!.phoneno = phoneno;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel!.uid)
        .set(widget.userModel!.toMap())
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: Text('Uploaded'),
        backgroundColor: Colors.blue,
      ));
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Homepage(
            userModel: widget.userModel, firebaseuser: widget.firebaseUser);
      }));
    });
  }

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedimage = await ImageCropper().cropImage(
        sourcePath: file.path,
        compressQuality: 80,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));
    if (croppedimage != null) {
      setState(() {
        imageFile = File(croppedimage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Upload Picture'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: Icon(Icons.photo_library),
                  title: Text('Select from Gallery'),
                ),
                ListTile(
                  leading: Icon(Icons.camera),
                  title: Text('Click photo'),
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Complete Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 35),
              child: ListView(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: () {
                      showPhotoOptions();
                    },
                    child: CircleAvatar(
                      backgroundImage:
                          (imageFile != null) ? FileImage(imageFile!) : null,
                      child: (imageFile == null) ? Icon(Icons.person_2) : null,
                      radius: 50,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: fullnamec,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Fullname'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: phonec,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'PhoneNo'),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                      width: 120,
                      height: 40,
                      child: ElevatedButton(
                          onPressed: () {
                            checkValues();
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return Login();
                              },
                            ));
                          },
                          child: Text('Submit')))
                ],
              )
              )
              ),
    );
  }
}
