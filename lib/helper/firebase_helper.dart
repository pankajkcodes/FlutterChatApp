import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterchatapp/models/user_model.dart';

class FirebaseHelper {
  static Future<UserModel?> getUserModelById(String id) async {
    UserModel? userModel;
    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("users").doc(id).get();
    if (docSnap.data() != null) {
      userModel = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
    }
    return userModel;
  }
}
