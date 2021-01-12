import 'package:chat_server/model/user.dart';

import 'harness/app.dart';

void main() {
  final harness = Harness()..install();

  test("GET /friend returns 200 OK", () async {
    final User userA = User();
    userA.username = "userA";
    userA.password = "12345";
    final User userB = User();
    userB.username = "userB";
    userB.password = "12345";

    final Agent agentA = await harness.registerUser(userA);
    final Agent agentB = await harness.registerUser(userB);

    final response = await agentA.get("/friend");
    expectResponse(response, 200, body: {
      "code": 1,
      "msg": "Requested friend list",
      "data": hasLength(greaterThanOrEqualTo(0))
    });
  });
}
