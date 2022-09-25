import 'dart:developer';

import 'package:signalr_core/signalr_core.dart';
import 'package:signalr_test/signal_r_protocol.dart';

class SignalRHelper {
  SignalRHelper._privateConstructor();

  static final SignalRHelper _instance = SignalRHelper._privateConstructor();
  factory SignalRHelper() {
    return _instance;
  }

  init(Function() onNotifyFunction) {
    _onNotify = onNotifyFunction;
  }

  Function()? _onNotify;

  void notifyListeners() {
    _onNotify?.call();
  }

  final String url = 'https://85c0-39-34-185-242.ap.ngrok.io/chatHub';
  final webSocketTime = 5 * (60 * 1000); // 5 minute refresh web socket
  HubConnection? hubConnection;
  String textMessage = '';

  Future<void> connect(receiveMessageHandler) async {
    try {
      hubConnection = HubConnectionBuilder()
          .withAutomaticReconnect(1000)
          .withUrl(url, HttpTransportType.webSockets)
          .withHubProtocol(CustomHubProtocol())
          .build();
      hubConnection?.on('ReceiveMessage', (arg) {
        if (arg != null && arg.isNotEmpty) {
          receiveMessageHandler(arg);
          notifyListeners();
        } else {
          log("SignalR empty");
        }
      });
      hubConnection?.onclose((error) {
        log('SignalR debugConnection Close');
      });
      log("SignalR debug ReceiveMessage init");
      await _start();
      notifyListeners();
    } catch (e) {
      log("SignalR debug $e");
    }
  }

  Future<void> sendMessage(
      {required String senderId,
      required String senderName,
      required String recipientId,
      required String recipientName,
      required String message,
      required String type}) async {
    if (await restartIfNeedIt()) {
      hubConnection?.invoke('SendMessage', args: [
        senderId,
        senderName,
        recipientId,
        recipientName,
        message,
        type
      ]);
      textMessage = '';
      notifyListeners();
    } else {
      return Future.error(Exception(
          'Cannot send Message because connection is in \'Disconnected\' state.'));
    }
  }

  Future<void> _start() async {
    await hubConnection?.start();
    log(hubConnection?.connectionId ?? "");
    log("SignalR debug connectionID");
  }

  bool isWorking() {
    return hubConnection != null ? hubConnection?.state?.index == 2 : false;
  }

  Future<void> disconnect() async {
    hubConnection?.stop();
    log("SignalR debug stop");
  }

  Future<void> reStart() async {
    await hubConnection?.stop();
    log("SignalR debug restarting");
    await _start();
    identify();
  }

  Future<bool> restartIfNeedIt() async {
    if (!isWorking()) {
      await reStart();
    } else {
      log("SignalR debug identity");
      identify();
    }
    return isWorking();
  }

  int? identify() =>
      hubConnection?.keepAliveIntervalInMilliseconds = webSocketTime;
}
