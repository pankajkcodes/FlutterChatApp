class UserModel {
  String? uid;
  String? name;
  String? email;
  String? profilePic;

  /// Default Constructor
  UserModel({this.uid, this.name, this.email, this.profilePic});

  /// Constructor For Convert data FROM MAP To USER MODEL
  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    name = map["name"];
    email = map["email"];
    profilePic = map["profilePic"];
  }

  /// Constructor For Convert USER MODEL TO MAP
  Map<String, dynamic> toMap() {
    return {"uid": uid, "name": name, "email": email, "profilePic": profilePic};
  }
}
