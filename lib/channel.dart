import 'package:aqueduct/managed_auth.dart';
import 'package:chat_server/config/custom_config.dart';
import 'package:chat_server/controller/chat_list_controller.dart';
import 'package:chat_server/controller/connect_controller.dart';
import 'package:chat_server/controller/friend_controller.dart';
import 'package:chat_server/controller/login_controller.dart';
import 'package:chat_server/controller/message_controller.dart';
import 'package:chat_server/controller/register_controller.dart';
import 'package:chat_server/model/message.dart';
import 'package:chat_server/model/user.dart';

import 'chat_server.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class ChatServerChannel extends ApplicationChannel {
  ManagedContext context;

  AuthServer authServer;

  Map<int, WebSocket> connections = {};

  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final config = CustomConfig(options.configurationFilePath);
    final dateModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        config.database.username,
        config.database.password,
        config.database.host,
        config.database.port,
        config.database.databaseName);

    context = ManagedContext(dateModel, persistentStore);

    final authStorage = ManagedAuthDelegate<User>(context);
    authServer = AuthServer(authStorage);

    messageHub.listen((event) {
      if (event is Map && event['event'] == 'websocket_direct_message') {
        final Message msg = Message();
        msg.readFromMap(event['message'] as Map<String, dynamic>);
        connections.values.forEach((socket) {
          final connectController =
              ConnectController(context, connections, messageHub);
          connectController.routeMessage(msg);
        });
      }
    });
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    router.route("/files/*").link(() => FileController("public/"));

    router.route("auth/token").link(() => AuthController(authServer));

    router
        .route("/register")
        .link(() => RegisterController(authServer, context));

    router.route("/login").link(() => LoginController(context));

    router
        .route("/friend")
        .link(() => Authorizer.bearer(authServer))
        .link(() => FriendController(context));

    router
        .route("/chat_list")
        .link(() => Authorizer.bearer(authServer))
        .link(() => ChatListController(context));

    router
        .route("/message/[:id]")
        .link(() => Authorizer.bearer(authServer))
        .link(() => MessageController(context));

    //Connect to server by websocket
    router
        .route("/connect")
        .link(() => Authorizer.bearer(authServer))
        .link(() => ConnectController(context, connections, messageHub));

    return router;
  }
}
