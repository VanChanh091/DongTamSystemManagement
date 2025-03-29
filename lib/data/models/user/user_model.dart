class User {
  final String fullName, email, password, sex, phone, role;

  User({
    required this.fullName,
    required this.email,
    required this.password,
    required this.sex,
    required this.phone,
    required this.role,
  });

  //change JSON from api to object User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['fullName'],
      email: json['email'],
      password: json['password'],
      sex: json['sex'],
      phone: json['phone'],
      role: json['role'],
    );
  }

  //change object User to JSON send to BE
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'sex': sex,
      'phone': phone,
      'role': role,
    };
  }
}
