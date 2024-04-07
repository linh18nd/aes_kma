enum MessageType {
  userInfo,
  file,
}

class User {
  String id;
  String name;
  bool isMe;

  User({required this.id, required this.name, required this.isMe});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      isMe: json['isMe'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isMe': isMe,
    };
  }
}
