import 'package:chat_server/chat_server.dart';

class CustomConfig extends Configuration {
  CustomConfig(String path) : super.fromFile(File(path));

  DatabaseConfiguration database;
}
