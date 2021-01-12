import 'package:chat_server/chat_server.dart';
import 'package:chat_server/model/base_result.dart';
import 'package:chat_server/model/user.dart';

/**
 * Register Port
 */
class RegisterController extends ResourceController {
  RegisterController(this.authServer, this.context);

  final AuthServer authServer;
  final ManagedContext context;

  @Operation.post()
  Future<Response> createUser(@Bind.body() User user) async {
    if (user.username.isNotEmpty != true || user.password.isNotEmpty != true) {
      return Response.ok(
        BaseResult(
          code: 1,
          msg: 'Register Failed: username and password required',
        ),
      );
    }

    //Check if user exists in database
    final Query<User> query = Query<User>(context)
      ..where((u) {
        return u.username;
      }).equalTo(user.username);

    if (await query.fetchOne() != null) {
      return Response.ok(
        BaseResult(
          code: 1,
          msg: 'Register Failed: user has already exist',
        ),
      );
    }

    //Insert user into database
    user
      ..salt = AuthUtility.generateRandomSalt()
      ..hashedPassword = authServer.hashPassword(user.password, user.salt);

    final result = await Query(context, values: user).insert();

    return Response.ok(
      BaseResult(
        code: 1,
        data: result,
        msg: "Register Successful",
      ),
    );
  }
}
