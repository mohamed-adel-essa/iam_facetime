class User {
  String user;
  String password;

  User({required this.user, required this.password});

  static User fromDB(String dbuser) {
    return User(user: dbuser.split(':')[0], password: dbuser.split(':')[1]);
  }
}

class UserModal {
  final String user;
  final String password;
  final String imagePath;

  UserModal({
    required this.user,
    required this.password,
    required this.imagePath,
  });

  factory UserModal.fromDp(Map<String, dynamic> map) {
    return UserModal(
      imagePath: map['image'],
      password: map['password'],
      user: map['username'],
    );
  }
}
