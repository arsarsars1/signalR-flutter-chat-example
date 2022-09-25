import 'dart:convert';

import 'package:flutter/material.dart';

import 'Models/message.dart';
import 'signal_r_helper.dart';

class ChatScreen extends StatefulWidget {
  final String name;

  const ChatScreen({Key? key, required this.name}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController txtController = TextEditingController();
  static List<MessageModel> messageList = <MessageModel>[];
  SignalRHelper signalRHelper = SignalRHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              itemCount: messageList.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(
                    messageList[i].isMine
                        ? messageList[i].message
                        : '${messageList[i].senderName}: ${messageList[i].message}',
                    textAlign:
                        messageList[i].isMine ? TextAlign.end : TextAlign.start,
                  ),
                );
              },
              separatorBuilder: (_, i) {
                return const Divider(
                  thickness: 2,
                );
              },
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: txtController,
                decoration: InputDecoration(
                  hintText: 'Send Message',
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.lightBlue,
                    ),
                    onPressed: () async {
                      await signalRHelper.restartIfNeedIt();
                      signalRHelper.sendMessage(
                          senderId: "${widget.name}12",
                          senderName: widget.name,
                          recipientId: "abdul12",
                          recipientName: "abdul",
                          message: txtController.text,
                          type: "text");
                      txtController.clear();
                      scrollController.jumpTo(
                          scrollController.position.maxScrollExtent + 75);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    signalRHelper.init(() {
      if (mounted) {
        setState(() {});
      }
    });
    signalRHelper.connect(receiveMessageHandler);
  }

  receiveMessageHandler(List<dynamic> args) {
    MessageModel messageModel = MessageModel.fromJson(json.decode(args[0]));
    print(messageModel.toJson());
    if (MessageModel.isValidAdd(messageModel, messageList) == false) {
      print("inside");
      messageModel.isMine = "${widget.name}12" == messageModel.senderId;
      messageList.add(messageModel);
      scrollController.jumpTo(scrollController.position.maxScrollExtent + 75);
      setState(() {});
    } else {
      print("else");
    }
  }

  @override
  void dispose() {
    txtController.dispose();
    scrollController.dispose();
    signalRHelper.disconnect();
    super.dispose();
  }
}
