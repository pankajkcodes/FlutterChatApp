class MessageModel {
  String? messageId;
  String? sender;
  String? message;
  bool? seen;
  DateTime? createdAt;

  MessageModel(
      {this.messageId, this.sender, this.message, this.seen, this.createdAt});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageId = map["messageId"];
    sender = map["sender"];
    message = map["message"];
    seen = map["seen"];
    createdAt = map["createdAt"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "messageId": messageId,
      "sender": sender,
      "message": message,
      "seen": seen,
      "createdAt": createdAt
    };
  }
}
