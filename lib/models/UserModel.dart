class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;
  String? phoneno;
  UserModel(
      {this.uid, this.fullname, this.email, this.profilepic, this.phoneno});
  //Deserialization
  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepic = map["profilepic"];
    phoneno = map["phoneno"];
  }
  //Serialization
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepic": profilepic,
      "phoneno":phoneno
    };
  }
}
