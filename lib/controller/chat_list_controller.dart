import 'package:chat_server/chat_server.dart';
import 'package:chat_server/model/base_result.dart';
import 'package:chat_server/model/user.dart';

/**
 * get chat list
 */
class ChatListController extends ResourceController {
  ChatListController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getFriends() async {
    final int fromUserId = request.authorization.ownerID;
    final Query<User> query = Query<User>(context)
      ..where((user) {
        return user.id;
      }).notEqualTo(fromUserId);
    final List<User> users = await query.fetch();

    return Response.ok(
      BaseResult(
        code: 1,
        msg: "Requested friend list",
        data: users,
      ),
    );
  }
}
