import 'package:chat_server/chat_server.dart';

/**
 * chat record
 */
class Message extends ManagedObject<_Message> implements _Message {
  @Serialize(input: true, output: true)
  bool selfUser; //check if the message belongs to the current user

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'content': content,
      'type': type,
      'sendTime': sendTime.toUtc().toString(),
      'selfUser': selfUser
    };
  }
}

class _Message {
  @Column(primaryKey: true, autoincrement: true)
  int id;

  @Column()
  int fromUserId; //Sender id
  @Column()
  int toUserId; //Receiver id
  @Column()
  String content; //Message content
  @Column()
  int type; //Message type
  @Column()
  DateTime sendTime; //Send time
}
