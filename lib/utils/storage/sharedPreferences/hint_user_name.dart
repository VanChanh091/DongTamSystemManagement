import 'package:shared_preferences/shared_preferences.dart';

class HintUserName {
  static const _key = 'username_used';

  HintUserName._privateConstructor();
  static final HintUserName instance = HintUserName._privateConstructor();

  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> usernames = prefs.getStringList(_key) ?? [];

    // Avoid duplicates, move to front
    usernames.remove(username);
    usernames.insert(0, username);

    // Keep only last 4
    if (usernames.length > 4) usernames = usernames.sublist(0, 4);

    await prefs.setStringList('username_used', usernames);
  }

  Future<List<String>> loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> removeOneUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> usernames = prefs.getStringList(_key) ?? [];

    usernames.remove(username);
    await prefs.setStringList('username_used', usernames);
  }
}
