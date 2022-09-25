import 'dart:convert';

import 'package:signalr_core/signalr_core.dart';

class CustomHubProtocol implements HubProtocol {
  @override
  String get name => jsonHubProtocolName;

  @override
  int get version => 1;

  @override
  TransferFormat get transferFormat => TransferFormat.text;

  /// Creates an array of [HubMessage] objects from the specified serialized representation.
  @override
  List<HubMessage?> parseMessages(dynamic input, Logging? logging) {
    // Only JsonContent is allowed.
    if (!(input is String)) {
      throw Exception(
          'Invalid input for JSON hub protocol. Expected a string.');
    }

    final jsonInput = input.replaceAll("null", "\"\"");
    final hubMessages = <HubMessage?>[];

    // ignore: unnecessary_null_comparison
    if (input == null) {
      return hubMessages;
    }

    // Parse the messages
    final messages = TextMessageFormat.parse(jsonInput);
    for (var message in messages) {
      message = message.replaceAll(":\"\"", ":null");
      final jsonData = json.decode(message);
      final messageType =
          _getMessageTypeFromJson(jsonData as Map<String, dynamic>);
      HubMessage? parsedMessage;

      switch (messageType) {
        case MessageType.invocation:
          parsedMessage = InvocationMessageExtensions.fromJson(jsonData);
          _isInvocationMessage(parsedMessage as InvocationMessage);
          break;
        case MessageType.streamItem:
          parsedMessage = StreamItemMessageExtensions.fromJson(jsonData);
          _isStreamItemMessage(parsedMessage as StreamItemMessage);
          break;
        case MessageType.completion:
          parsedMessage = CompletionMessageExtensions.fromJson(jsonData);
          _isCompletionMessage(parsedMessage as CompletionMessage);
          break;
        case MessageType.ping:
          parsedMessage = PingMessageExtensions.fromJson(jsonData);
          // Single value, no need to validate
          break;
        case MessageType.close:
          parsedMessage = CloseMessageExtensions.fromJson(jsonData);
          // All optional values, no need to validate
          break;
        default:
          // Future protocol changes can add message types, old clients can ignore them
          logging!(LogLevel.information,
              'Unknown message type \'${parsedMessage!.type}\' ignored.');
          continue;
      }
      hubMessages.add(parsedMessage);
    }

    return hubMessages;
  }

  /// Writes the specified [HubMessage] to a string and returns it.
  @override
  String? writeMessage(HubMessage message) {
    switch (message.type) {
      case MessageType.undefined:
        break;
      case MessageType.invocation:
        return TextMessageFormat.write(
            json.encode((message as InvocationMessage).toJson()));
      case MessageType.streamItem:
        return TextMessageFormat.write(
            json.encode((message as StreamItemMessage).toJson()));
      case MessageType.completion:
        return TextMessageFormat.write(
            json.encode((message as CompletionMessage).toJson()));
      case MessageType.streamInvocation:
        return TextMessageFormat.write(
            json.encode((message as StreamInvocationMessage).toJson()));
      case MessageType.cancelInvocation:
        return TextMessageFormat.write(
            json.encode((message as CancelInvocationMessage).toJson()));
      case MessageType.ping:
        return TextMessageFormat.write(
            json.encode((message as PingMessage).toJson()));
      case MessageType.close:
        return TextMessageFormat.write(
            json.encode((message as CloseMessage).toJson()));
      default:
        break;
    }
    return null;
  }

  static MessageType _getMessageTypeFromJson(Map<String, dynamic> json) {
    switch (json['type'] as int?) {
      case 0:
        return MessageType.undefined;
      case 1:
        return MessageType.invocation;
      case 2:
        return MessageType.streamItem;
      case 3:
        return MessageType.completion;
      case 4:
        return MessageType.streamInvocation;
      case 5:
        return MessageType.cancelInvocation;
      case 6:
        return MessageType.ping;
      case 7:
        return MessageType.close;
      default:
        return MessageType.undefined;
    }
  }

  void _isInvocationMessage(InvocationMessage message) {
    _assertNotEmptyString(
        message.target, 'Invalid payload for Invocation message.');

    if (message.invocationId != null) {
      _assertNotEmptyString(
          message.target, 'Invalid payload for Invocation message.');
    }
  }

  void _isStreamItemMessage(StreamItemMessage message) {
    _assertNotEmptyString(
        message.invocationId, 'Invalid payload for StreamItem message.');

    if (message.item == null) {
      throw Exception('Invalid payload for StreamItem message.');
    }
  }

  void _isCompletionMessage(CompletionMessage message) {
    if ((message.result == null) && (message.error != null)) {
      _assertNotEmptyString(
          message.error, 'Invalid payload for Completion message.');
    }

    _assertNotEmptyString(
        message.invocationId, 'Invalid payload for Completion message.');
  }

  void _assertNotEmptyString(dynamic value, String errorMessage) {
    if ((value is String == false) || (value as String).isEmpty) {
      throw Exception(errorMessage);
    }
  }
}