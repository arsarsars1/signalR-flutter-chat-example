import 'dart:convert';

import 'package:intl/intl.dart';

class MessageModel {
  String senderId;
  String senderName;
  String receiverId;
  String receiverName;
  String type;
  String message;
  DateTime createdAt;
  bool isMine = false;

  MessageModel({
    required this.type,
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.createdAt,
    this.isMine = false,
  });

  MessageModel.fromJson(Map<String, dynamic> data)
      : senderId = data['SenderId'] ?? '',
        senderName = data['SenderName'] ?? '',
        receiverId = data['ReceiverId'] ?? '',
        receiverName = data['ReceiverName'] ?? '',
        type = data['Type'] ?? '',
        message = data['Message'] ?? '',
        createdAt = data['CreatedAt'].toIso8601String();

  Map<String, dynamic> toJson() => {
        "SenderId": senderId,
        "SenderName": senderName,
        "ReceiverId": receiverId,
        "ReceiverName": receiverName,
        "Type": type,
        "Message": message,
        "CreatedAt": createdAt
      };

  static bool isValidAdd(MessageModel message, List<MessageModel> messageList) {
    return messageList.any((element) =>
        element.senderId == message.senderId &&
        element.receiverId == message.receiverId &&
        element.message == message.message);
  }

  static List<MessageModel> parseListModel(String str) =>
      List<MessageModel>.from(
          json.decode(str).map((x) => MessageModel.fromJson(x)));

  static String formatDateChat(int? time) {
    var date = DateTime.fromMillisecondsSinceEpoch(time!);
    return DateFormat("dd/MM/yyyy HH:mm").format(date);
  }
}
