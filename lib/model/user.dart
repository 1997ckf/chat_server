import 'package:aqueduct/managed_auth.dart';

import 'package:chat_server/chat_server.dart';

class User extends ManagedObject<_User>
    implements _User, ManagedAuthResourceOwner<_User> {
  @Serialize(input: true, output: false)
  String password;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'tokens': tokens
    };
  }
}

class _User extends ResourceOwnerTableDefinition {}
