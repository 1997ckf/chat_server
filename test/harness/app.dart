import 'package:chat_server/chat_server.dart';
import 'package:aqueduct_test/aqueduct_test.dart';
import 'package:chat_server/model/user.dart';

export 'package:chat_server/chat_server.dart';
export 'package:aqueduct_test/aqueduct_test.dart';
export 'package:test/test.dart';
export 'package:aqueduct/aqueduct.dart';

/// A testing harness for chat_server.
///
/// A harness for testing an aqueduct application. Example test file:
///
///         void main() {
///           Harness harness = Harness()..install();
///
///           test("GET /path returns 200", () async {
///             final response = await harness.agent.get("/path");
///             expectResponse(response, 200);
///           });
///         }
///
class Harness extends TestHarness<ChatServerChannel>
    with TestHarnessAuthMixin<ChatServerChannel>, TestHarnessORMMixin {
  @override
  AuthServer get authServer => channel.authServer;
  @override
  ManagedContext get context => channel.context;

  Agent publicAgent;

  @override
  Future onSetUp() async {
    await resetData();
    publicAgent =
        await addClient("com.1997ckf.chat_server", secret: "myspecialsecret");
  }

  Future<Agent> registerUser(User user, {Agent withClient}) async {
    withClient ??= publicAgent;

    final req = withClient.request("/register")
      ..body = {"username": user.username, "password": user.password};
    await req.post();

    return loginUser(withClient, user.username, user.password);
  }
}
