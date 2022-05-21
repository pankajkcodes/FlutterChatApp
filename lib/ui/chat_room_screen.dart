import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterchatapp/models/message_model.dart';
import 'package:flutterchatapp/models/user_model.dart';

import '../models/chat_room_model.dart';

class ChatRoomScreen extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatRoomModel;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomScreen(
      {Key? key,
      required this.targetUser,
      required this.chatRoomModel,
      required this.userModel,
      required this.firebaseUser})
      : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    if (msg.isNotEmpty) {
      // SEND MESSAGE
      MessageModel newMessage = MessageModel(
          messageId: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: widget.userModel.uid,
          createdAt: DateTime.now(),
          message: msg,
          seen: false);
      FirebaseFirestore.instance
          .collection("chatroom")
          .doc(widget.chatRoomModel.chatRoomId)
          .collection("messages")
          .doc(newMessage.messageId)
          .set(newMessage.toMap());
      widget.chatRoomModel.lastMessage = msg; 
      FirebaseFirestore.instance.collection("chatroom")
      .doc(widget.chatRoomModel.chatRoomId).set(widget.chatRoomModel.toMap());

      log("Message Sent!");

      messageController.clear();
    } else {
      // DO Nothing

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.grey,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(widget.targetUser.name.toString())
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("chatroom")
                        .doc(widget.chatRoomModel.chatRoomId)
                        .collection("messages")
                        .orderBy("createdAt", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapShot =
                              snapshot.data as QuerySnapshot;

                          return ListView.builder(
                              reverse: true,
                              itemCount: dataSnapShot.docs.length,
                              itemBuilder: (context, index) {
                                MessageModel currentMessage =
                                    MessageModel.fromMap(
                                        dataSnapShot.docs[index].data()
                                            as Map<String, dynamic>);

                                return Row(
                                  mainAxisAlignment: (currentMessage.sender ==
                                          widget.userModel.uid)
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 2),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        decoration: BoxDecoration(
                                            color: (currentMessage.sender ==
                                                    widget.userModel.uid)
                                                ? Colors.grey
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        child: Text(
                                            currentMessage.message.toString(),
                                        style: const TextStyle(color: Colors.white),)),
                                  ],
                                );
                              });
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text("Something Went Wrong !"));
                        } else {
                          return const Center(child: Text("Say Hi"));
                        }
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Flexible(
                        child: TextField(
                      controller: messageController,
                      maxLines: null,
                      decoration: const InputDecoration(hintText: "Type...."),
                    )),
                    IconButton(
                        onPressed: () {
                          sendMessage();
                        },
                        icon: const Icon(Icons.send))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
