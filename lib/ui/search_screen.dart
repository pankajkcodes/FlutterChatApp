import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterchatapp/ui/chat_room_screen.dart';
import '../models/user_model.dart';

class SearchScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchScreen({
    Key? key, required this.userModel, required this.firebaseUser,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(hintText: "Search by email"),
              ),
              const SizedBox(
                height: 20,
              ),
              CupertinoButton(
                  child: const Text("Search"),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  onPressed: () {
                    setState(() {

                    });
                  }),

              StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("users")
                      .where("email", isEqualTo: searchController.text)
                      .where("email", isNotEqualTo: widget.userModel.email).snapshots(),
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.active) {
                      if(snapshot.hasData) {
                        QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                        if(dataSnapshot.docs.isNotEmpty) {
                          Map<String, dynamic> userMap = dataSnapshot.docs[0].data() as Map<String, dynamic>;

                          UserModel searchedUser = UserModel.fromMap(userMap);

                          return ListTile(
                            onTap: () async {
                          //    ChatRoomModel? chatroomModel = await getChatroomModel(searchedUser);

                              // if(chatroomModel != null) {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return const ChatRoomScreen(
                                        // targetUser: searchedUser,
                                        // userModel: widget.userModel,
                                        // firebaseUser: widget.firebaseUser,
                                        // chatroom: chatroomModel,
                                      );
                                    }
                                ));
                              // }
                            },
                            leading: CircleAvatar(
                             // backgroundImage: NetworkImage(searchedUser.profilepic!),
                              backgroundColor: Colors.grey[500],
                            ),
                            title: Text(searchedUser.name!),
                            subtitle: Text(searchedUser.email!),
                            trailing: const Icon(Icons.keyboard_arrow_right),
                          );
                        }
                        else {
                          return const Text("No results found!");
                        }

                      }
                      else if(snapshot.hasError) {
                        return const Text("An error occurred!");
                      }
                      else {
                        return const Text("No results found!");
                      }
                    }
                    else {
                      return const CircularProgressIndicator();
                    }
                  }
              ),

            ],

          ),
        ),
      ),
    );
  }
}
