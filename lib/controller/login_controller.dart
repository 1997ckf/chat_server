import 'dart:convert';

import 'package:chat_server/chat_server.dart';
import 'package:chat_server/model/base_result.dart';
import 'package:chat_server/model/user.dart';
import 'package:http/http.dart' as http;

/**
 * Login Portal
 */
class LoginController extends ResourceController {
  LoginController(this.context);

  final ManagedContext context;

  @Operation.post()
  Future<Response> login(@Bind.body() User user) async {
    String msg = "Login Failed";
    //Check if the user exists
    final query = Query<User>(context)
      ..where((u) => u.username).equalTo(user.username);
    final User result = await query.fetchOne();

    if (result == null) {
      msg = "User does not exist";
    } else {
      //Request auth/token to get a token. Respond the token if login successfully
      const clientId = "com.1997ckf.chat_server";
      const clientSecret = "myspecialsecret";
      final body =
          "username=${user.username}&password=${user.password}&grant_type=password";
      final clientCredentials =
          const Base64Encoder().convert("$clientId:$clientSecret".codeUnits);

      final http.Response response =
          await http.post("http://localhost:8888/auth/token",
              headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                "Authorization": "Basic $clientCredentials"
              },
              body: body);

      if (response.statusCode == 200) {
        final map = json.decode(response.body);

        return Response.ok(
          BaseResult(
            code: 1,
            msg: "Login Successful",
            data: {
              'userId': result.id,
              'access_token': map['access_token'],
              'userName': result.username
            },
          ),
        );
      }
    }

    return Response.ok(
      BaseResult(
        code: 1,
        msg: msg,
      ),
    );
  }
}

//class BasicValidator implements
