class User {
  int? idUser;
  String username;
  String email;
  String pass;

  User({
    this.idUser,
    required this.username,
    required this.email,
    required this.pass,
  });

  // Chuyển từ Map thành đối tượng User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      idUser: map['idUser'],
      username: map['username'],
      email: map['email'],
      pass: map['pass'],
    );
  }

  // Chuyển từ User thành Map để lưu trữ trong SQLite
  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
      'username': username,
      'email': email,
      'pass': pass,
    };
  }
}