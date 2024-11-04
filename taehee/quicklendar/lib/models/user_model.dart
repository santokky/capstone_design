class User {
  final String name;
  final String email;
  final String phone;
  final String token;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.token,
  });

  // JSON 데이터를 User 객체로 변환하는 factory constructor
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      token: json['token'],
    );
  }

  // User 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'token': token,
    };
  }
}
