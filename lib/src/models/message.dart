class Message {
  Message({
    this.key,
    this.senderId,
    this.message,
    this.seen,
    this.createdAt,
    this.receiverId,
    this.senderName,
    this.timeStamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        key: json['key'] as String,
        senderId: json['sender_id'] as String,
        message: json['message'] as String,
        seen: json['seen'] as bool,
        createdAt: json['created_at'] as String,
        timeStamp: json['timeStamp'] as String,
        senderName: json['senderName'] as String,
        receiverId: json['receiverId'] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'sender_id': senderId,
        'message': message,
        'receiverId': receiverId,
        'seen': seen,
        'created_at': createdAt,
        'senderName': senderName,
        'timeStamp': timeStamp
      };

  String key;
  String senderId;
  String message;
  bool seen;
  String createdAt;
  String timeStamp;

  String senderName;
  String receiverId;
}
