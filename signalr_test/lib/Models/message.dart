import 'dart:convert';

import 'package:intl/intl.dart';

class MessageModel {
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String type;
  final String message;
  final DateTime createdAt;
  bool isMine;

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

  factory MessageModel.fromJson(Map<String, dynamic> data) => MessageModel(
      senderId: data['senderId'],
      senderName: data['senderName'],
      receiverId: data['receiverId'],
      receiverName: data['receiverName'],
      type: data['type'],
      message: data['message'],
      createdAt: DateTime.parse(data["createdAt"]));

  Map<String, dynamic> toJson() => {
        "senderId": senderId,
        "senderName": senderName,
        "receiverId": receiverId,
        "receiverName": receiverName,
        "type": type,
        "message": message,
        "createdAt": createdAt
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
