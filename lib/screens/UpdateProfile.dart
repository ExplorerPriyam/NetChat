import 'package:chatapp/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/screens/Homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UpdateProfile extends StatefulWidget {
  final UserModel? userModel;
  final User? fireBaseUser;

  const UpdateProfile(
      {super.key, required this.userModel, required this.fireBaseUser});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  File? imageFile;
  var fullnamec = TextEditingController();
  var phonec = TextEditingController();
  @override
  void initState() {
    super.initState();
    fullnamec.text = widget.userModel!.fullname.toString();
    phonec.text = widget.userModel!.phoneno.toString();
  }

  void uploadData() async {
    if (imageFile != null) {
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
          content: Text('Updated'),
          backgroundColor: Colors.blue,
        ));
      });
      setState(() {});
    } else {
      String? fullname = fullnamec.text;
      String? phoneno = phonec.text;
      widget.userModel!.fullname = fullname;
      widget.userModel!.phoneno = phoneno;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userModel!.uid)
          .set(widget.userModel!.toMap())
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
          content: Text('Updated'),
          backgroundColor: Colors.blue,
        ));
      });
      setState(() {});
    }
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
        automaticallyImplyLeading: true,
        title: Text('Update Profile'),
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
                      child: (imageFile == null)
                          ? Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(140),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                        widget.userModel!.profilepic.toString(),
                                      ))),
                            )
                          : null,
                      radius: 50,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: fullnamec,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Username'),
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
                          onPressed: () async {
                            setState(() {});
                            uploadData();
                            setState(() {
                              Future.delayed(Duration(seconds: 1), () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(
                                  builder: (context) {
                                    return Homepage(
                                        userModel: widget.userModel,
                                        firebaseuser: widget.fireBaseUser);
                                  },
                                ));
                              });
                            });
                          },
                          child: Text('Submit')))
                ],
              ))),
    );
  }
}
