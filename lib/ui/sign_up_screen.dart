import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterchatapp/models/user_model.dart';
import 'package:flutterchatapp/ui/profile_screen.dart';
import 'package:flutterchatapp/ui/sign_in_screen.dart';
import 'package:flutterchatapp/utils/snackbar.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void checkValue() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();
    if (email.isEmpty || password.isEmpty || cPassword.isEmpty) {
      showSnackBar(context, "Can't be Empty!");
    } else if (password != cPassword) {
      showSnackBar(context, "Password not matched!");
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(context, 'The account already exists for that email.');
      }
    } catch (e) {
      showSnackBar(context, e.toString());
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const SignInScreen();
      }));
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newModel =
          UserModel(uid: uid, name: "", email: email, profilePic: "");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newModel.toMap())
          .then((value) => showSnackBar(context, "Successfully Signed Up !"));
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ProfileScreen(
            userModel: newModel, firebaseUser: credential!.user!);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 45),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Chat App",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 45,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: emailController,
                    decoration:
                        const InputDecoration(hintText: "Email Address"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: "Password"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: cPasswordController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(hintText: "Confirm Password"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    child: const Text("Sign Up"),
                    onPressed: () {
                      checkValue();
                    },
                    color: Theme.of(context).colorScheme.secondary,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account?"),
              CupertinoButton(
                child: const Text("Sign In"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          )),
    );
  }
}
