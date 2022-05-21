import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterchatapp/models/chat_room_model.dart';
import 'package:flutterchatapp/utils/constants.dart';

import '../models/user_model.dart';
import 'chat_room_screen.dart';

class SearchScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchScreen({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatroom")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Fetch Existing Chat Room
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatRoom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatRoom;

      log("Chat Room already Created");
    } else {
      // Create New Chat Room
      log("Chat Room Created");

      ChatRoomModel newChatRoom = ChatRoomModel(
          chatRoomId: Constants.uniqueId,
          lastMessage: "",
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true
          });

      await FirebaseFirestore.instance
          .collection("chatroom")
          .doc(newChatRoom.chatRoomId)
          .set(newChatRoom.toMap());

      chatRoom = newChatRoom;
    }
    return chatRoom;
  }

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
                              ChatRoomModel? chatroomModel =
                                  await getChatRoomModel(searchedUser);

                              if(chatroomModel != null) {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return ChatRoomScreen(
                                        targetUser: searchedUser,
                                        userModel: widget.userModel,
                                        firebaseUser: widget.firebaseUser,
                                       chatRoomModel: chatroomModel,
                                      );
                                    }
                                ));
                              }
                            },
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(searchedUser.profilePic!),
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
