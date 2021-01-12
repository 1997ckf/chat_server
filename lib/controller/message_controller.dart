import 'package:chat_server/chat_server.dart';
import 'package:chat_server/model/base_result.dart';
import 'package:chat_server/model/message.dart';

/**
 * Message Port
 */
class MessageController extends ResourceController {
  MessageController(this.context);

  final ManagedContext context;

  /**
   * Check chat record
   */
  @Operation.get()
  Future<Response> getMessage({
    @Bind.query('fromId') int fromId,
    @Bind.query('toId') int toId,
  }) async {
    List<Message> messageList;
    Query<Message> query;

    if (fromId == null && toId == null) {
      query = Query<Message>(context)
        ..sortBy((message) {
          return message.sendTime;
        }, QuerySortOrder.ascending);
    } else if (fromId != null && toId == null) {
      query = Query<Message>(context)
        ..where((message) {
          return message.fromUserId;
        }).equalTo(fromId)
        ..sortBy((message) {
          return message.sendTime;
        }, QuerySortOrder.ascending);
    } else if (fromId == null && toId != null) {
      query = Query<Message>(context)
        ..where((message) {
          return message.toUserId;
        }).equalTo(toId)
        ..sortBy((message) {
          return message.sendTime;
        }, QuerySortOrder.ascending);
    } else {
      query = Query<Message>(context)
        ..where((message) {
          return message.toUserId;
        }).oneOf([fromId, toId])
        ..where((message) {
          return message.fromUserId;
        }).oneOf([fromId, toId])
        ..sortBy((message) {
          return message.sendTime;
        }, QuerySortOrder.ascending);
    }
    messageList = await query.fetch();

    messageList.forEach((message) {
      if (message.fromUserId == request.authorization.ownerID) {
        message.selfUser = true;
      } else {
        message.selfUser = false;
      }
    });

    return Response.ok(
      BaseResult(
        code: 1,
        msg: "Requested chat records",
        data: messageList,
      ),
    );
  }
}
