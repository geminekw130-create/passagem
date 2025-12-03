import 'package:hive/hive.dart';

final box = Hive.box('appBox');

class UserData {
  saveLoginData(String key, String value) {
    box.put(key, value);
  }
}
