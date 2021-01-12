import 'dart:async';
import 'dart:convert' as convert;

import 'package:chat_server/chat_server.dart';
import 'package:chat_server/model/message.dart';

class ConnectController extends Controller {
  ConnectController(this.context, this.connections, this.messageHub);

  final ManagedContext context;

  final Map<int, WebSocket> connections;

  final ApplicationMessageHub messageHub;

  @override
  FutureOr<RequestOrResponse> handle(Request request) async {
    //get user id
    final userId = request.authorization.ownerID;
    await WebSocketTransformer.upgrade(request.raw).then((websocket) {
      websocket
          .listen((event) => handleEvent(event, fromUserId: userId))
          .onDone(() {
        //remove the connection if the socket disconnected
        connections.remove(userId);
      });
      //Keep the connections in map
      connections[userId] = websocket;
    });

    print("$userId has connected to server");
    return null;
  }

  void handleEvent(dynamic event, {int fromUserId}) async {
    print("server listen: ${event}");
    if (event is String) {
      try {
        final map = convert.jsonDecode(event.toString());

        final int toUserId = map['toUserId'] as int;
        final String msgContent = map['msg_content'] as String;
        final int msgType = map['msg_type'] as int;

        final Message message = Message();
        message
          ..fromUserId = fromUserId
          ..toUserId = toUserId
          ..content = msgContent
          ..type = msgType
          ..sendTime = DateTime.now();

        final Message returnMessage = await saveMessage(message);
        if (returnMessage != null) {
          routeMessage(message);
          messageHub.add(
            {
              "event": "websocket_direct_message",
              "message": message.asMap(),
            },
          );
        }
      } catch (e) {
        print("Error: $e");
      }
    } else {
      messageHub.add(
        {
          "event": "websocket_broadcast",
          "message": event,
          'fromUserId': fromUserId,
        },
      );
    }
  }

  void routeMessage(Message message) {
    connections.keys.forEach((key) {
      if (key == message.toUserId || key == message.fromUserId) {
        final bool selfUser = key == message.fromUserId;
        message.selfUser = selfUser;
        connections[key].add(convert.jsonEncode(message));
        print(
            "Server redirecting the message： fromUserId:${message.fromUserId},toUserId:${message.toUserId},msg_content: ${message.content}");
      }
    });
  }

  /**
   * Save a message to database
   */
  Future<Message> saveMessage(Message message) async {
    final Query<Message> query = Query<Message>(context)..values = message;

    final Message insertResult = await query.insert();
    if (insertResult != null) {
      print("Successfully saved the message：${message.asMap()}");
      return insertResult;
    } else {
      return null;
    }
  }
}
