class UserUserModel {
  final String? fullName, email, password, role;
  final String? sex, phone, avatar;
  final List<String> permissions;

  UserUserModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.sex,
    this.phone,
    this.avatar,
    required this.permissions,
  });

  //change JSON from api to object User
  factory UserUserModel.fromJson(Map<String, dynamic> json) {
    return UserUserModel(
      fullName: json['fullName'] ?? "",
      email: json['email'] ?? "",
      password: json['password'] ?? "",
      sex: json['sex'] ?? "",
      phone: json['phone'] ?? "",
      avatar: json['avatar'] ?? "",
      role: json['role'],
      permissions: List<String>.from(json['permissions'] ?? []),
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
      'avatar': avatar,
      'permissions': permissions,
    };
  }
}
