

import 'user_provider.dart';
import '../model/user.dart';

class UserLocalProvider implements UserProvider {
  final List<User> users = [
    for (int i in List.generate(15, (i) => i))
      User(fullName: "Bad Boys", phone: "What r u", passwordHash: "imageUrl", balance: 0.0)
  ];

  @override
  addUser(User user) async {
    return users.add(user);
  }

  @override
  editUser(String id, User user) async {
    int index = -1;
    for (int i = 0; i < users.length; i++) {
      if (users[i].id == id) {
        index = i;
        break;
      }
    }

    if (index == -1) {
      throw Exception("User not found");
    }

    users[index] = User(
        fullName: user.fullName,
        phone: user.phone,
        passwordHash: user.passwordHash,
        balance: user.balance);
  }

  @override
  Future<User> getUser(String id) async {
    for (int i = 0; i < users.length; i++) {
      if (users[i].id == id) {
        return users[i];
      }
    }

    throw Exception('User not found');
  }

  @override
  Future<List<User>> getAllUsers() async {
    return users;
  }
}
