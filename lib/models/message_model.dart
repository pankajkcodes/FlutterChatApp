class MessageModel {
  String? sender;
  String? message;
  bool? seen;
  DateTime? createdAt;

  MessageModel(this.sender, this.message, this.seen, this.createdAt);


  MessageModel.fromMap(Map<String, dynamic> map) {
    sender = map["sender"];
    message = map["message"];
    seen = map["seen"];
    createdAt = map["createdAt"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "sender": sender,
      "message": message,
      "seen": seen,
      "createdAt": createdAt
    };
  }
}
